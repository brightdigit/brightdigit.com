/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Publish
import Files

final class DeploymentTests: PublishTestCase {
    private var defaultCommandLineArguments: [String]!

    override func setUp() {
        super.setUp()
        defaultCommandLineArguments = CommandLine.arguments
    }

    override func tearDown() {
        CommandLine.arguments = defaultCommandLineArguments
        super.tearDown()
    }

    func testDeploymentSkippedByDefault() throws {
        var deployed = false

        try publishWebsite(using: [
            .step(named: "Custom") { _ in },
            .deploy(using: DeploymentMethod(name: "Deploy") { _ in
                deployed = true
            })
        ])

        XCTAssertFalse(deployed)
    }

    func testGenerationStepsAndPluginsSkippedWhenDeploying() throws {
        CommandLine.arguments.append("--deploy")

        var generationPerformed = false
        var pluginInstalled = false

        try publishWebsite(using: [
            .step(named: "Skipped") { _ in
                generationPerformed = true
            },
            .installPlugin(Plugin(name: "Skipped") { _ in
                pluginInstalled = true
            }),
            .deploy(using: DeploymentMethod(name: "Deploy") { _ in })
        ])

        XCTAssertFalse(generationPerformed)
        XCTAssertFalse(pluginInstalled)
    }

    func testDeployingUsingCustomOutputFolder() throws {
        let container = try Folder.createTemporary()

        // First generate
        try publishWebsite(in: container, using: [
            .addMarkdownFiles(),
            .generateHTML(withTheme: .foundation)
        ], content: [
            "one/a.md": "Text"
        ])

        // Then deploy
        CommandLine.arguments.append("--deploy")

        var outputFolder: Folder?

        try publishWebsite(in: container, using: [
            .deploy(using: DeploymentMethod(name: "Test") { context in
                outputFolder = try context.createDeploymentFolder(
                    withPrefix: "Test",
                    outputFolderPath: "CustomOutput",
                    configure: { _ in }
                )
            })
        ])

        let folder = try require(outputFolder)
        let subfolder = try folder.subfolder(named: "CustomOutput")
        XCTAssertTrue(subfolder.containsSubfolder(at: "one/a"))
    }
}
