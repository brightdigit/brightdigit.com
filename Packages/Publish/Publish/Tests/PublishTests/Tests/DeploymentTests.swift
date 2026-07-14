/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
@testable import Publish
import Files

final class DeploymentTests: PublishTestCase {
    func testDeploymentSkippedByDefault() throws {
        let deployed = LockIsolated(false)

        try publishWebsite(using: [
            .step(named: "Custom") { _ in },
            .deploy(using: DeploymentMethod(name: "Deploy") { _ in
                deployed.value = true
            })
        ])

        XCTAssertFalse(deployed.value)
    }

    func testGenerationStepsAndPluginsSkippedWhenDeploying() throws {
        let generationPerformed = LockIsolated(false)
        let pluginInstalled = LockIsolated(false)

        try PublishRuntimeOverride.$commandLineArguments.withValue(["publish", "--deploy"]) {
            try publishWebsite(using: [
                .step(named: "Skipped") { _ in
                    generationPerformed.value = true
                },
                .installPlugin(Plugin(name: "Skipped") { _ in
                    pluginInstalled.value = true
                }),
                .deploy(using: DeploymentMethod(name: "Deploy") { _ in })
            ])
        }

        XCTAssertFalse(generationPerformed.value)
        XCTAssertFalse(pluginInstalled.value)
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
        let outputFolder = LockIsolated<Folder?>(nil)

        try PublishRuntimeOverride.$commandLineArguments.withValue(["publish", "--deploy"]) {
            try publishWebsite(in: container, using: [
                .deploy(using: DeploymentMethod(name: "Test") { context in
                    outputFolder.value = try context.createDeploymentFolder(
                        withPrefix: "Test",
                        outputFolderPath: "CustomOutput",
                        configure: { _ in }
                    )
                })
            ])
        }

        let folder = try require(outputFolder.value)
        let subfolder = try folder.subfolder(named: "CustomOutput")
        XCTAssertTrue(subfolder.containsSubfolder(at: "one/a"))
    }
}
