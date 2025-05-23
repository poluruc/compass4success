import Foundation

class RubricLoader {
    // Cache for loaded rubrics
    private static var cachedRubrics: [RubricTemplate]?
    private static var lastLoadTime: Date?
    private static let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    static func loadAllRubrics() -> [RubricTemplate] {
        // Return cached rubrics if they exist and haven't expired
        if let cached = cachedRubrics,
           let lastLoad = lastLoadTime,
           Date().timeIntervalSince(lastLoad) < cacheTimeout {
            return cached
        }
        
        print("🔍 Starting to load rubrics...")
        var templates: [RubricTemplate] = []
        let decoder = JSONDecoder()
        var seenIds = Set<String>()
        let fileManager = FileManager.default

        // 1. Load from app bundle Resources/Rubrics
        if let bundleJsonFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            print("📦 Found \(bundleJsonFiles.count) bundle rubric JSON files")
            for file in bundleJsonFiles {
                do {
                    let data = try Data(contentsOf: file)
                    let template = try decoder.decode(RubricTemplate.self, from: data)
                    if !seenIds.contains(template.id) {
                        templates.append(template)
                        seenIds.insert(template.id)
                    }
                } catch {
                    print("❌ Error decoding bundle rubric \(file.lastPathComponent): \(error)")
                }
            }
            if let bundleRubricsURL = Bundle.main.resourceURL?.appendingPathComponent("Rubrics") {
                print("❌ Could not find any rubric JSON files in bundle Rubrics directory. Tried path: \(bundleRubricsURL.path)")
            }
        } else {
            // Try to print the directory path being searched
            if let bundleRubricsURL = Bundle.main.resourceURL?.appendingPathComponent("Rubrics") {
                print("❌ Could not find any rubric JSON files in bundle Rubrics directory. Tried path: \(bundleRubricsURL.path)")
            } else {
                print("❌ Could not construct bundle Rubrics directory path.")
            }
        }

        // 2. Load from user's Documents/Rubrics
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access documents directory")
            return templates
        }
        let rubricsPath = documentsPath.appendingPathComponent("Rubrics")
        print("📂 Rubrics path: \(rubricsPath.path)")
        do {
            try fileManager.createDirectory(at: rubricsPath, withIntermediateDirectories: true)
        } catch {
            print("❌ Error creating Rubrics directory: \(error)")
            return templates
        }
        // Check if we need to copy default rubrics
        do {
            let existingFiles = try fileManager.contentsOfDirectory(at: rubricsPath, includingPropertiesForKeys: nil)
            if existingFiles.isEmpty {
                print("📝 No existing rubrics found, creating defaults...")
                try createDefaultRubrics(in: rubricsPath)
            }
        } catch {
            print("❌ Error checking rubrics directory: \(error)")
            return templates
        }
        // Load all rubrics from Documents
        do {
            let files = try fileManager.contentsOfDirectory(at: rubricsPath, includingPropertiesForKeys: nil)
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            print("📄 Found \(jsonFiles.count) user rubric JSON files")
            for file in jsonFiles {
                do {
                    let data = try Data(contentsOf: file)
                    let template = try decoder.decode(RubricTemplate.self, from: data)
                    if !seenIds.contains(template.id) {
                        templates.append(template)
                        seenIds.insert(template.id)
                    }
                } catch {
                    print("❌ Error decoding user rubric \(file.lastPathComponent): \(error)")
                }
            }
        } catch {
            print("❌ Error loading user rubrics: \(error)")
        }
        
        print("✨ Finished loading \(templates.count) unique rubrics")
        
        // Update cache
        cachedRubrics = templates
        lastLoadTime = Date()
        
        return templates
    }
    
    // Force reload rubrics from disk
    static func reloadRubrics() {
        cachedRubrics = nil
        lastLoadTime = nil
        _ = loadAllRubrics()
    }
    
    private static func createDefaultRubrics(in directory: URL) throws {
        let defaultRubrics: [(String, String)] = [
            ("jk_writing", """
            {
                "id": "jk_writing",
                "title": "JK Writing Skills",
                "rubricDescription": "Evaluates early writing and mark-making skills for Junior Kindergarten students",
                "applicableGrades": [0],
                "criteria": [
                    {
                        "name": "Mark Making",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Makes random marks on paper"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Makes controlled marks and basic shapes"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Creates recognizable shapes and letters"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Forms clear letters and shapes with good control"
                            }
                        ]
                    },
                    {
                        "name": "Name Writing",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Attempts to write name with support"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Writes some letters of name independently"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Writes full name with few errors"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Writes name clearly and consistently"
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
                "rubricDescription": "Evaluates mathematical problem-solving skills for Grade 3 students",
                "applicableGrades": [3],
                "criteria": [
                    {
                        "name": "Understanding",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Shows limited understanding of the problem"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Shows some understanding of the problem"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Shows good understanding of the problem"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Shows thorough understanding of the problem"
                            }
                        ]
                    },
                    {
                        "name": "Strategy & Procedures",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Uses limited or inappropriate strategies"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Uses some appropriate strategies"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Uses appropriate and effective strategies"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Uses innovative and highly effective strategies"
                            }
                        ]
                    },
                    {
                        "name": "Communication",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Explains thinking with limited clarity"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Explains thinking with some clarity"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Explains thinking clearly and completely"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Explains thinking with exceptional clarity and detail"
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
                "rubricDescription": "Comprehensive writing assessment for Grade 5 students focusing on organization, ideas, and conventions",
                "applicableGrades": [5],
                "criteria": [
                    {
                        "name": "Ideas & Content",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Basic ideas with limited development"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Ideas are generally focused with some development"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Clear, developed ideas with supporting details"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Rich, detailed ideas with thorough development"
                            }
                        ]
                    },
                    {
                        "name": "Organization",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Limited organization and structure"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Basic organization with some transitions"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Clear organization with effective transitions"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Sophisticated organization enhancing clarity"
                            }
                        ]
                    },
                    {
                        "name": "Language & Style",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Simple language with limited variety"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Some variety in language and sentence structure"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Effective language and varied sentence structure"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Rich language with sophisticated style"
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
                "rubricDescription": "Assesses scientific inquiry and communication for Grade 7 students",
                "applicableGrades": [7],
                "criteria": [
                    {
                        "name": "Questioning & Predicting",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Rarely asks questions or makes predictions"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Sometimes asks relevant questions or makes predictions"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Often asks thoughtful questions and makes logical predictions"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Consistently asks insightful questions and makes well-reasoned predictions"
                            }
                        ]
                    },
                    {
                        "name": "Planning & Conducting",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Needs support to plan and conduct investigations"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Plans and conducts simple investigations with some support"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Independently plans and conducts effective investigations"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Designs and conducts complex investigations with precision"
                            }
                        ]
                    },
                    {
                        "name": "Communicating Results",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Communicates results with limited clarity"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Communicates results with some clarity and detail"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Clearly communicates results with appropriate detail"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Communicates results with exceptional clarity and insight"
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
                "rubricDescription": "Evaluates literary analysis and writing skills for Grade 10 students",
                "applicableGrades": [10],
                "criteria": [
                    {
                        "name": "Thesis & Argument",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Thesis is unclear or missing; argument is weak"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Thesis is present but basic; argument is somewhat developed"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Clear thesis and well-developed argument"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Insightful thesis and sophisticated, compelling argument"
                            }
                        ]
                    },
                    {
                        "name": "Evidence & Support",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Little or no evidence provided"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Some evidence provided, but not always relevant or explained"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Relevant evidence is provided and explained"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Extensive, well-chosen evidence with insightful explanation"
                            }
                        ]
                    },
                    {
                        "name": "Organization & Style",
                        "levels": [
                            {
                                "level": 1,
                                "rubricTemplateLevelDescription": "Disorganized and unclear writing style"
                            },
                            {
                                "level": 2,
                                "rubricTemplateLevelDescription": "Some organization; writing style is basic"
                            },
                            {
                                "level": 3,
                                "rubricTemplateLevelDescription": "Well-organized and clear writing style"
                            },
                            {
                                "level": 4,
                                "rubricTemplateLevelDescription": "Exceptionally organized and engaging writing style"
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
