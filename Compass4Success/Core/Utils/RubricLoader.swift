import Foundation

class RubricLoader {
    static func loadAllRubrics() -> [RubricTemplate] {
        print("🔍 Starting to load rubrics...")
        
        // Get the document directory path
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access documents directory")
            return []
        }
        
        let rubricsPath = documentsPath.appendingPathComponent("Rubrics")
        print("📂 Rubrics path: \(rubricsPath.path)")
        
        // Create Rubrics directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: rubricsPath, withIntermediateDirectories: true)
        } catch {
            print("❌ Error creating Rubrics directory: \(error)")
            return []
        }
        
        // Check if we need to copy default rubrics
        let fileManager = FileManager.default
        do {
            let existingFiles = try fileManager.contentsOfDirectory(at: rubricsPath, includingPropertiesForKeys: nil)
            if existingFiles.isEmpty {
                print("📝 No existing rubrics found, creating defaults...")
                try createDefaultRubrics(in: rubricsPath)
            }
        } catch {
            print("❌ Error checking rubrics directory: \(error)")
            return []
        }
        
        // Load all rubrics
        do {
            let files = try fileManager.contentsOfDirectory(at: rubricsPath, includingPropertiesForKeys: nil)
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            print("📄 Found \(jsonFiles.count) JSON files")
            
            var templates: [RubricTemplate] = []
            let decoder = JSONDecoder()
            
            for file in jsonFiles {
                print("📝 Processing file: \(file.lastPathComponent)")
                do {
                    let data = try Data(contentsOf: file)
                    let template = try decoder.decode(RubricTemplate.self, from: data)
                    templates.append(template)
                    print("✅ Successfully loaded rubric: \(template.title)")
                } catch {
                    print("❌ Error decoding \(file.lastPathComponent): \(error)")
                }
            }
            
            print("✨ Finished loading \(templates.count) rubrics")
            return templates
            
        } catch {
            print("❌ Error loading rubrics: \(error)")
            return []
        }
    }
    
    private static func createDefaultRubrics(in directory: URL) throws {
        let defaultRubrics: [(String, String)] = [
            ("jk_writing", """
            {
                "id": "jk_writing",
                "title": "JK Writing Skills",
                "description": "Evaluates early writing and mark-making skills for Junior Kindergarten students",
                "applicableGrades": [0],
                "criteria": [
                    {
                        "name": "Mark Making",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Makes random marks on paper"
                            },
                            {
                                "level": 2,
                                "description": "Makes controlled marks and basic shapes"
                            },
                            {
                                "level": 3,
                                "description": "Creates recognizable shapes and letters"
                            },
                            {
                                "level": 4,
                                "description": "Forms clear letters and shapes with good control"
                            }
                        ]
                    },
                    {
                        "name": "Name Writing",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Attempts to write name with support"
                            },
                            {
                                "level": 2,
                                "description": "Writes some letters of name independently"
                            },
                            {
                                "level": 3,
                                "description": "Writes full name with few errors"
                            },
                            {
                                "level": 4,
                                "description": "Writes name clearly and consistently"
                            }
                        ]
                    }
                ]
            }
            """),
            ("grade3_math", """
            {
                "id": "grade3_math",
                "title": "Grade 3 Math Problem Solving",
                "description": "Evaluates mathematical problem-solving skills for Grade 3 students",
                "applicableGrades": [3],
                "criteria": [
                    {
                        "name": "Understanding",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Shows limited understanding of the problem"
                            },
                            {
                                "level": 2,
                                "description": "Shows some understanding of the problem"
                            },
                            {
                                "level": 3,
                                "description": "Shows good understanding of the problem"
                            },
                            {
                                "level": 4,
                                "description": "Shows thorough understanding of the problem"
                            }
                        ]
                    },
                    {
                        "name": "Strategy & Procedures",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Uses limited or inappropriate strategies"
                            },
                            {
                                "level": 2,
                                "description": "Uses some appropriate strategies"
                            },
                            {
                                "level": 3,
                                "description": "Uses appropriate and effective strategies"
                            },
                            {
                                "level": 4,
                                "description": "Uses innovative and highly effective strategies"
                            }
                        ]
                    },
                    {
                        "name": "Communication",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Explains thinking with limited clarity"
                            },
                            {
                                "level": 2,
                                "description": "Explains thinking with some clarity"
                            },
                            {
                                "level": 3,
                                "description": "Explains thinking clearly and completely"
                            },
                            {
                                "level": 4,
                                "description": "Explains thinking with exceptional clarity and detail"
                            }
                        ]
                    }
                ]
            }
            """),
            ("grade5_writing", """
            {
                "id": "grade5_writing",
                "title": "Grade 5 Writing Assessment",
                "description": "Comprehensive writing assessment for Grade 5 students focusing on organization, ideas, and conventions",
                "applicableGrades": [5],
                "criteria": [
                    {
                        "name": "Ideas & Content",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Basic ideas with limited development"
                            },
                            {
                                "level": 2,
                                "description": "Ideas are generally focused with some development"
                            },
                            {
                                "level": 3,
                                "description": "Clear, developed ideas with supporting details"
                            },
                            {
                                "level": 4,
                                "description": "Rich, detailed ideas with thorough development"
                            }
                        ]
                    },
                    {
                        "name": "Organization",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Limited organization and structure"
                            },
                            {
                                "level": 2,
                                "description": "Basic organization with some transitions"
                            },
                            {
                                "level": 3,
                                "description": "Clear organization with effective transitions"
                            },
                            {
                                "level": 4,
                                "description": "Sophisticated organization enhancing clarity"
                            }
                        ]
                    },
                    {
                        "name": "Language & Style",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Simple language with limited variety"
                            },
                            {
                                "level": 2,
                                "description": "Some variety in language and sentence structure"
                            },
                            {
                                "level": 3,
                                "description": "Effective language and varied sentence structure"
                            },
                            {
                                "level": 4,
                                "description": "Rich language with sophisticated style"
                            }
                        ]
                    }
                ]
            }
            """),
            ("grade7_science", """
            {
                "id": "grade7_science",
                "title": "Grade 7 Science Inquiry Skills",
                "description": "Assesses scientific inquiry and communication for Grade 7 students",
                "applicableGrades": [7],
                "criteria": [
                    {
                        "name": "Questioning & Predicting",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Rarely asks questions or makes predictions"
                            },
                            {
                                "level": 2,
                                "description": "Sometimes asks relevant questions or makes predictions"
                            },
                            {
                                "level": 3,
                                "description": "Often asks thoughtful questions and makes logical predictions"
                            },
                            {
                                "level": 4,
                                "description": "Consistently asks insightful questions and makes well-reasoned predictions"
                            }
                        ]
                    },
                    {
                        "name": "Planning & Conducting",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Needs support to plan and conduct investigations"
                            },
                            {
                                "level": 2,
                                "description": "Plans and conducts simple investigations with some support"
                            },
                            {
                                "level": 3,
                                "description": "Independently plans and conducts effective investigations"
                            },
                            {
                                "level": 4,
                                "description": "Designs and conducts complex investigations with precision"
                            }
                        ]
                    },
                    {
                        "name": "Communicating Results",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Communicates results with limited clarity"
                            },
                            {
                                "level": 2,
                                "description": "Communicates results with some clarity and detail"
                            },
                            {
                                "level": 3,
                                "description": "Clearly communicates results with appropriate detail"
                            },
                            {
                                "level": 4,
                                "description": "Communicates results with exceptional clarity and insight"
                            }
                        ]
                    }
                ]
            }
            """),
            ("grade10_english", """
            {
                "id": "grade10_english",
                "title": "Grade 10 English Literary Analysis",
                "description": "Evaluates literary analysis and writing skills for Grade 10 students",
                "applicableGrades": [10],
                "criteria": [
                    {
                        "name": "Thesis & Argument",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Thesis is unclear or missing; argument is weak"
                            },
                            {
                                "level": 2,
                                "description": "Thesis is present but basic; argument is somewhat developed"
                            },
                            {
                                "level": 3,
                                "description": "Clear thesis and well-developed argument"
                            },
                            {
                                "level": 4,
                                "description": "Insightful thesis and sophisticated, compelling argument"
                            }
                        ]
                    },
                    {
                        "name": "Evidence & Support",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Little or no evidence provided"
                            },
                            {
                                "level": 2,
                                "description": "Some evidence provided, but not always relevant or explained"
                            },
                            {
                                "level": 3,
                                "description": "Relevant evidence is provided and explained"
                            },
                            {
                                "level": 4,
                                "description": "Extensive, well-chosen evidence with insightful explanation"
                            }
                        ]
                    },
                    {
                        "name": "Organization & Style",
                        "levels": [
                            {
                                "level": 1,
                                "description": "Disorganized and unclear writing style"
                            },
                            {
                                "level": 2,
                                "description": "Some organization; writing style is basic"
                            },
                            {
                                "level": 3,
                                "description": "Well-organized and clear writing style"
                            },
                            {
                                "level": 4,
                                "description": "Exceptionally organized and engaging writing style"
                            }
                        ]
                    }
                ]
            }
            """)
        ]
        
        for (filename, content) in defaultRubrics {
            let fileURL = directory.appendingPathComponent("\(filename).json")
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ Created default rubric: \(filename)")
        }
    }
} 