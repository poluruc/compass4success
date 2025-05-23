import Foundation
import RealmSwift

// A struct to hold mock data for the app
struct MockData {
    var students: [Student]
    var classes: [SchoolClass]
    var assignments: [Assignment]
    var grades: [Grade]
}

// Service to generate mock data for previews and development
class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    // Create a set of mock data for development and testing
    func generateMockData() -> MockData {
        // Create students
        let student1 = Student()
        student1.id = "S001"
        student1.firstName = "John"
        student1.lastName = "Smith"
        student1.email = "john.smith@school.edu"
        student1.grade = "9"
        student1.studentNumber = "123456"
        
        let student2 = Student()
        student2.id = "S002"
        student2.firstName = "Emily"
        student2.lastName = "Johnson"
        student2.email = "emily.johnson@school.edu"
        student2.grade = "9"
        student2.studentNumber = "123457"
        
        let student3 = Student()
        student3.id = "S003"
        student3.firstName = "Michael"
        student3.lastName = "Williams"
        student3.email = "michael.williams@school.edu"
        student3.grade = "9"
        student3.studentNumber = "123458"
        
        let student4 = Student()
        student4.id = "S004"
        student4.firstName = "Olivia"
        student4.lastName = "Brown"
        student4.email = "olivia.brown@school.edu"
        student4.grade = "9"
        student4.studentNumber = "123459"
        
        let student5 = Student()
        student5.id = "S005"
        student5.firstName = "James"
        student5.lastName = "Davis"
        student5.email = "james.davis@school.edu"
        student5.grade = "10"
        student5.studentNumber = "123460"
        
        let student6 = Student()
        student6.id = "S006"
        student6.firstName = "Sophia"
        student6.lastName = "Miller"
        student6.email = "sophia.miller@school.edu"
        student6.grade = "10"
        student6.studentNumber = "123461"
        
        let student7 = Student()
        student7.id = "S007"
        student7.firstName = "Benjamin"
        student7.lastName = "Wilson"
        student7.email = "benjamin.wilson@school.edu"
        student7.grade = "10"
        student7.studentNumber = "123462"
        
        let student8 = Student()
        student8.id = "S008"
        student8.firstName = "Ava"
        student8.lastName = "Moore"
        student8.email = "ava.moore@school.edu"
        student8.grade = "10"
        student8.studentNumber = "123463"
        
        let student9 = Student()
        student9.id = "S009"
        student9.firstName = "Ethan"
        student9.lastName = "Taylor"
        student9.email = "ethan.taylor@school.edu"
        student9.grade = "11"
        student9.studentNumber = "123464"
        
        let student10 = Student()
        student10.id = "S010"
        student10.firstName = "Isabella"
        student10.lastName = "Anderson"
        student10.email = "isabella.anderson@school.edu"
        student10.grade = "11"
        student10.studentNumber = "123465"
        
        // Create classes
        let mathClass = SchoolClass()
        mathClass.id = "C001"
        mathClass.name = "Algebra 2"
        mathClass.clazzCode = "MATH201"
        mathClass.subject = "Mathematics"
        mathClass.gradeLevel = "9"
        mathClass.period = 1
        mathClass.roomNumber = "101"
        mathClass.teacherId = "T001"
        mathClass.schoolYear = "2024-2025"
        mathClass.semester = "Spring"
        
        let scienceClass = SchoolClass()
        scienceClass.id = "C002"
        scienceClass.name = "Biology"
        scienceClass.clazzCode = "SCI101"
        scienceClass.subject = "Science"
        scienceClass.gradeLevel = "9"
        scienceClass.period = 2
        scienceClass.roomNumber = "205"
        scienceClass.teacherId = "T001"
        scienceClass.schoolYear = "2024-2025"
        scienceClass.semester = "Spring"
        
        let historyClass = SchoolClass()
        historyClass.id = "C003"
        historyClass.name = "World History"
        historyClass.clazzCode = "HIST101"
        historyClass.subject = "History"
        historyClass.gradeLevel = "10"
        historyClass.period = 3
        historyClass.roomNumber = "304"
        historyClass.teacherId = "T001"
        historyClass.schoolYear = "2024-2025"
        historyClass.semester = "Spring"
        
        let englishClass = SchoolClass()
        englishClass.id = "C004"
        englishClass.name = "English Literature"
        englishClass.clazzCode = "ENG201"
        englishClass.subject = "English"
        englishClass.gradeLevel = "10"
        englishClass.period = 4
        englishClass.roomNumber = "202"
        englishClass.teacherId = "T001"
        englishClass.schoolYear = "2024-2025"
        englishClass.semester = "Spring"
        
        let codingClass = SchoolClass()
        codingClass.id = "C005"
        codingClass.name = "Computer Science"
        codingClass.clazzCode = "CS101"
        codingClass.subject = "Technology"
        codingClass.gradeLevel = "11"
        codingClass.period = 5
        codingClass.roomNumber = "Lab 1"
        codingClass.teacherId = "T001"
        codingClass.schoolYear = "2024-2025"
        codingClass.semester = "Spring"
        
        // Add students to classes
        let mathStudents = List<Student>()
        mathStudents.append(student1)
        mathStudents.append(student2)
        mathStudents.append(student3)
        mathStudents.append(student4)
        mathClass.students = mathStudents
        
        let scienceStudents = List<Student>()
        scienceStudents.append(student1)
        scienceStudents.append(student2)
        scienceStudents.append(student5)
        scienceStudents.append(student6)
        scienceClass.students = scienceStudents
        
        let historyStudents = List<Student>()
        historyStudents.append(student5)
        historyStudents.append(student6)
        historyStudents.append(student7)
        historyStudents.append(student8)
        historyClass.students = historyStudents
        
        let englishStudents = List<Student>()
        englishStudents.append(student7)
        englishStudents.append(student8)
        englishStudents.append(student9)
        englishStudents.append(student10)
        englishClass.students = englishStudents
        
        let codingStudents = List<Student>()
        codingStudents.append(student3)
        codingStudents.append(student4)
        codingStudents.append(student9)
        codingStudents.append(student10)
        codingClass.students = codingStudents
        
        // Create assignments
        let currentDate = Date()
        
        // Math Assignments
        let mathQuiz = Assignment(
            id: "A001",
            title: "Algebra Quiz 1",
            dueDate: currentDate.addingTimeInterval(86400 * 2), // 2 days from now
            assignmentDescription: "Quiz covering linear equations"
        )
        mathQuiz.rubricId = "grade3_math"
        
        let mathHomework = Assignment(
            id: "A002",
            title: "Algebra Homework",
            dueDate: currentDate.addingTimeInterval(86400 * 4), // 4 days from now
            assignmentDescription: "Problems 1-20 in Chapter 3"
        )
        mathHomework.rubricId = "grade3_math"
        
        // Science Assignments
        let scienceProject = Assignment(
            id: "A003",
            title: "Biology Lab Report",
            dueDate: currentDate.addingTimeInterval(86400 * 7), // 1 week from now
            assignmentDescription: "Write up the results of our cell division experiment"
        )
        scienceProject.rubricId = "grade7_science"
        
        let scienceQuiz = Assignment(
            id: "A004",
            title: "Cell Structure Quiz",
            dueDate: currentDate.addingTimeInterval(86400 * 1), // Tomorrow
            assignmentDescription: "Quiz covering cell organelles and their functions"
        )
        scienceQuiz.rubricId = "grade7_science"
        
        // History Assignments
        let historyEssay = Assignment(
            id: "A005",
            title: "World War II Essay",
            dueDate: currentDate.addingTimeInterval(86400 * 10), // 10 days from now
            assignmentDescription: "1500 word essay on the causes of World War II"
        )
        historyEssay.rubricId = "grade7_science" // Placeholder rubric for history
        
        // English Assignments
        let englishPaper = Assignment(
            id: "A006",
            title: "Shakespeare Analysis",
            dueDate: currentDate.addingTimeInterval(86400 * 14), // 2 weeks from now
            assignmentDescription: "Character analysis of Hamlet"
        )
        englishPaper.rubricId = "grade10_english"
        
        // Coding Assignments
        let codingProject = Assignment(
            id: "A007",
            title: "Mobile App Project",
            dueDate: currentDate.addingTimeInterval(86400 * 21), // 3 weeks from now
            assignmentDescription: "Develop a simple iOS app using Swift"
        )
        codingProject.rubricId = nil
        
        // Add assignments to classes
        let mathAssignments = List<Assignment>()
        mathAssignments.append(mathQuiz)
        mathAssignments.append(mathHomework)
        mathClass.assignments = mathAssignments
        
        let scienceAssignments = List<Assignment>()
        scienceAssignments.append(scienceProject)
        scienceAssignments.append(scienceQuiz)
        scienceClass.assignments = scienceAssignments
        
        let historyAssignments = List<Assignment>()
        historyAssignments.append(historyEssay)
        historyClass.assignments = historyAssignments
        
        let englishAssignments = List<Assignment>()
        englishAssignments.append(englishPaper)
        englishClass.assignments = englishAssignments
        
        let codingAssignments = List<Assignment>()
        codingAssignments.append(codingProject)
        codingClass.assignments = codingAssignments
        
        // Create collections for the mock data
        let students = [student1, student2, student3, student4, student5, student6, student7, student8, student9, student10]
        let classes = [mathClass, scienceClass, historyClass, englishClass, codingClass]
        let assignments = [mathQuiz, mathHomework, scienceProject, scienceQuiz, historyEssay, englishPaper, codingProject]
        
        // After creating students and classes, assign overall grades by adding courses with finalGrade to each student

        // Example: John Smith (student1) - strong student
        let johnMath = SchoolClass()
        johnMath.name = "Algebra 2"
        johnMath.finalGrade = 95
        let johnScience = SchoolClass()
        johnScience.name = "Biology"
        johnScience.finalGrade = 92
        student1.courses.append(objectsIn: [johnMath, johnScience])

        // Emily Johnson (student2) - good student
        let emilyMath = SchoolClass()
        emilyMath.name = "Algebra 2"
        emilyMath.finalGrade = 88
        let emilyScience = SchoolClass()
        emilyScience.name = "Biology"
        emilyScience.finalGrade = 85
        student2.courses.append(objectsIn: [emilyMath, emilyScience])

        // Michael Williams (student3) - average
        let michaelMath = SchoolClass()
        michaelMath.name = "Algebra 2"
        michaelMath.finalGrade = 78
        let michaelScience = SchoolClass()
        michaelScience.name = "Biology"
        michaelScience.finalGrade = 80
        student3.courses.append(objectsIn: [michaelMath, michaelScience])

        // Olivia Brown (student4) - below average
        let oliviaMath = SchoolClass()
        oliviaMath.name = "Algebra 2"
        oliviaMath.finalGrade = 65
        let oliviaScience = SchoolClass()
        oliviaScience.name = "Biology"
        oliviaScience.finalGrade = 70
        student4.courses.append(objectsIn: [oliviaMath, oliviaScience])

        // James Davis (student5) - strong
        let jamesHistory = SchoolClass()
        jamesHistory.name = "World History"
        jamesHistory.finalGrade = 91
        let jamesScience = SchoolClass()
        jamesScience.name = "Biology"
        jamesScience.finalGrade = 89
        student5.courses.append(objectsIn: [jamesHistory, jamesScience])

        // Sophia Miller (student6) - excellent
        let sophiaEnglish = SchoolClass()
        sophiaEnglish.name = "English Literature"
        sophiaEnglish.finalGrade = 98
        let sophiaScience = SchoolClass()
        sophiaScience.name = "Biology"
        sophiaScience.finalGrade = 94
        student6.courses.append(objectsIn: [sophiaEnglish, sophiaScience])

        // Benjamin Wilson (student7) - good
        let benHistory = SchoolClass()
        benHistory.name = "World History"
        benHistory.finalGrade = 85
        let benEnglish = SchoolClass()
        benEnglish.name = "English Literature"
        benEnglish.finalGrade = 87
        student7.courses.append(objectsIn: [benHistory, benEnglish])

        // Ava Moore (student8) - average
        let avaHistory = SchoolClass()
        avaHistory.name = "World History"
        avaHistory.finalGrade = 75
        let avaEnglish = SchoolClass()
        avaEnglish.name = "English Literature"
        avaEnglish.finalGrade = 78
        student8.courses.append(objectsIn: [avaHistory, avaEnglish])

        // Ethan Taylor (student9) - below average
        let ethanCoding = SchoolClass()
        ethanCoding.name = "Computer Science"
        ethanCoding.finalGrade = 68
        let ethanEnglish = SchoolClass()
        ethanEnglish.name = "English Literature"
        ethanEnglish.finalGrade = 72
        student9.courses.append(objectsIn: [ethanCoding, ethanEnglish])

        // Isabella Anderson (student10) - strong
        let isabellaCoding = SchoolClass()
        isabellaCoding.name = "Computer Science"
        isabellaCoding.finalGrade = 93
        let isabellaEnglish = SchoolClass()
        isabellaEnglish.name = "English Literature"
        isabellaEnglish.finalGrade = 90
        student10.courses.append(objectsIn: [isabellaCoding, isabellaEnglish])
        
        // Generate random grades for each student-assignment pair
        var generatedGrades: [Grade] = []
        for student in students {
            for assignment in assignments {
                let randomScore = Double.random(in: 60...100)
                let grade = Grade(studentId: student.id, 
                                assignmentId: assignment.id, 
                                classId: assignment.classId ?? "",
                                score: randomScore,
                                maxScore: 100)
                grade.isMissing = Bool.random() && randomScore < 70
                grade.isIncomplete = Bool.random() && randomScore < 80
                // Attach a rubricScoreId if the assignment has a rubric
                if let rubricId = assignment.rubricId, !rubricId.isEmpty {
                    grade.rubricScoreId = "mock_rubric_score_\(assignment.id)_\(student.id)"
                }
                generatedGrades.append(grade)
            }
        }
        // Add sample comments to about half the grades
        let sampleComments = ["Great job!", "Needs improvement", "See me after class", "Excellent work", "Missing explanation", "Check your calculations", "Well done", "Incomplete submission"]
        for i in 0..<generatedGrades.count {
            if i % 2 == 0 {
                generatedGrades[i].comments = sampleComments.randomElement()!
            } else {
                generatedGrades[i].comments = ""
            }
        }
        return MockData(students: students, classes: classes, assignments: assignments, grades: generatedGrades)
    }
}
