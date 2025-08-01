// Document Insertion and Embedding
db.students.insertMany([
  {
    _id: 1,
    name: "Alice",
    courses: [
      { code: "CS101", grade: "A" },
      { code: "MA101", grade: "B+" },
    ],
  },
  {
    _id: 2,
    name: "Bob",
    courses: [
      { code: "CS101", grade: "A-" },
      { code: "PH101", grade: "B" },
    ],
  },
]);

db.courses.insertMany([
  { _id: "CS101", title: "Intro to CS", credits: 4 },
  { _id: "MA101", title: "Calculus I", credits: 3 },
  { _id: "PH101", title: "Physics I", credits: 3 },
]);

// Querying and Projections
db.students.find({ name: "Alice" }, { _id: 0, name: 1, courses: 1 });

// Nested Field Queries and Updates
db.students.updateOne(
  { name: "Bob", "courses.code": "PH101" },
  { $set: { "courses.$.grade": "A" } }
);

// Aggregation Pipeline
db.students.aggregate([
  { $unwind: "$courses" },
  {
    $lookup: {
      from: "courses",
      localField: "courses.code",
      foreignField: "_id",
      as: "courseDetails",
    },
  },
  { $unwind: "$courseDetails" },
  {
    $group: {
      _id: "$name",
      totalCredits: { $sum: "$courseDetails.credits" },
    },
  },
]);

// Transactions
const session = db.getMongo().startSession();
const students = session.getDatabase("university").students;
const courses = session.getDatabase("university").courses;
session.startTransaction();
try {
  students.insertOne({ _id: 3, name: "Charlie", courses: [] });
  courses.updateOne(
    { _id: "CS101" },
    { $set: { title: "Intro to Computer Science" } }
  );
  session.commitTransaction();
} catch (e) {
  session.abortTransaction();
  print("Transaction aborted: " + e);
}

// Indexing
db.students.createIndex({ name: 1 });
db.courses.createIndex({ credits: -1 });

// Schema Validation
db.createCollection("grades", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["studentId", "courseCode", "grade"],
      properties: {
        studentId: { bsonType: "int" },
        courseCode: { bsonType: "string" },
        grade: { bsonType: "string" },
      },
    },
  },
});

db.grades.insertOne({ studentId: 1, courseCode: "CS101", grade: "A+" });
