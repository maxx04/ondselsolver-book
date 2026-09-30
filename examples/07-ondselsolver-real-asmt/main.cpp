#include "ASMTAssembly.h"

#include <filesystem>
#include <iostream>
#include <stdexcept>

int main(int argc, char* argv[]) {
    const std::filesystem::path inputPath = argc > 1 ? argv[1] : DEFAULT_ASMT_FILE;
    const std::filesystem::path outputPath = argc > 2
        ? argv[2]
        : inputPath.parent_path() / (inputPath.stem().string() + "-solved.asmt");

    try {
        auto assembly = MbD::ASMTAssembly::assemblyFromFile(inputPath.string());
        std::cout << "ASMT-Datei: " << inputPath << '\n';
        std::cout << "Teile vor Solve: " << assembly->parts->size() << '\n';

        assembly->solve();
        assembly->outputFile(outputPath.string());

        std::cout << "Solve abgeschlossen.\n";
        std::cout << "ASMT-Ergebnis: " << outputPath << '\n';
        return 0;
    } catch (const std::exception& error) {
        std::cerr << "OndselSolver konnte die ASMT-Datei nicht verarbeiten: "
                  << error.what() << '\n';
        return 1;
    }
}