import Foundation
import Swiftline
import ColorizeSwift
import CommandLineKit

let cli = CommandLineKit.CommandLine()
let dirPath = StringOption(shortFlag: "t", longFlag: "filetypes",
  helpMessage: "List all the types of files in current directory")

cli.addOptions(dirPath)

do {
  try cli.parse()
} catch {
  cli.printUsage(error)
}

var extensions = [String]() // Array to hold types of files present in the given directory
let fileManager = FileManager.default
let dirURL = URL(fileURLWithPath: dirPath.value!)

do {
  // FileURLs contains urls of all the files in the given directory
  let fileURLs = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)

  // Getting the unique file filetypes
  for file in fileURLs {
    if !extensions.contains(file.pathExtension) {
      extensions.append(file.pathExtension)
    }
  }

  // To remove an empty string at the beginning
  extensions.remove(at: 0)

  print("\n")
  print("Found \(extensions.count) types of files:".bold().blue())
  print("\n")
  print(extensions.joined(separator: " ").bold())

  let fileType = ask("Choose the file type to be grouped into a folder...".bold().green())
  print("\n")
  let choice = agree("Are you sure you want to group files of type: \(fileType)?".bold().white().onRed())

  if(choice == true) {
    print("\n")
    let dirName = ask("Choose the folder name to store files of type: \(fileType)".bold().blue())
    print("\n")
    print("Grouping files by chosen filetype".bold().green())
    let baseDirPath = dirPath.value!
    let newDirPath = baseDirPath + dirName + "/"
    let _ = run("mkdir", args: newDirPath)

    var numOfFilesMoved = 0

    for file in fileURLs {
      if(file.pathExtension == fileType) {
        do {
          try fileManager.moveItem(atPath: file.path, toPath: newDirPath + file.lastPathComponent)
          numOfFilesMoved = numOfFilesMoved + 1
        } catch let error as NSError {
          print("Ooops! Couldn't move the file: \(file.lastPathComponent) because of error: \(error)")
        }
      }
    }
  }
} catch {
  print("Error whiile enumerating files \(error.localizedDescription)")
}
