#include <h5pp/h5pp.h>

int main() {
    size_t logLevel = 2; // Set log level (default is 2: "info")

    // Initialize a file
    h5pp::File file("exampledir/example-07b-move-file.h5", h5pp::FilePermission::REPLACE, logLevel);

    // Write a dummy dataset
    file.writeDataset("A", "groupA/A");

    // Print the current location
    h5pp::print("File is currently in path: {}\n", file.getFilePath());

    // Move the file to another path
    file.moveFileTo("exampledir/subdir/example-step7-move-file.h5", h5pp::FilePermission::REPLACE);

    // Print the new current location (should change to the new path!)
    h5pp::print("File is now in a new path: {}\n", file.getFilePath());
}