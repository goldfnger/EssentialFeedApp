//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 21.12.2022.
//

import XCTest

extension XCTestCase {

  // 'assert' should be used instead of 'record' when correct snapshots are taken and main goal of tests is to compare existing snapshots with testing one
  func assert(snapshot: UIImage, named name: String,  file: StaticString = #file, line: UInt = #line) {
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

    guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
      XCTFail("Failed to load stored snapshot at url: \(snapshotURL). Use the 'record' method to store a snapshot before asserting.", file: file, line: line)
      return
    }

    if snapshotData != storedSnapshotData {
      let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent(snapshotURL.lastPathComponent)

      try? snapshotData?.write(to: temporarySnapshotURL)

      XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
    }
  }

  // in tests 'record' should be used when need to take a snapshot of view OR when required to update existing snapshots with new UI changes. (in case of error first need to make sure that snapshot looks correctly!)
  func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

    do {
      try FileManager.default.createDirectory(
        at: snapshotURL.deletingLastPathComponent(),
        withIntermediateDirectories: true)

      try snapshotData?.write(to: snapshotURL)
      XCTFail("Record succeeded - use 'assert' to compare the snapshot from now on.", file: file, line: line)
    } catch {
      XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
    }
  }

  private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
    return URL(fileURLWithPath: String(describing: file))
      .deletingLastPathComponent()
      .appendingPathComponent("snapshots")
      .appendingPathComponent("\(name).png")
  }

  private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
    guard let data = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
      return nil
    }

    return data
  }
}
