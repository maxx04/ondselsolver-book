#include <iostream>
#include <string>
#include <vector>

struct ModelPart {
    std::string id;
    double x;
    double y;
    double z;
    double rx;
    double ry;
    double rz;
};

struct AssemblyInput {
    std::vector<std::string> parts;
    std::vector<std::string> jointTypes;
};

struct SolverResult {
    std::string id;
    double x;
    double y;
    double z;
    double rz;
};

int main() {
    AssemblyInput input{{"base", "arm"}, {"grounded", "revolute"}};
    std::vector<SolverResult> result = {
        {"base", 0.0, 0.0, 0.0, 0.0},
        {"arm", 2.0, 0.0, 0.0, 0.8},
    };

    std::cout << "FreeCAD-Input:\n";
    for (const auto& part : input.parts) {
        std::cout << " - " << part << "\n";
    }
    for (const auto& joint : input.jointTypes) {
        std::cout << " - Joint: " << joint << "\n";
    }

    std::cout << "\nSolver-Ergebnis:\n";
    for (const auto& item : result) {
        std::cout << " - " << item.id << ": (x=" << item.x << ", y=" << item.y << ", z=" << item.z
                  << ", rz=" << item.rz << ")\n";
    }

    std::cout << "\nInterpretation: FreeCAD liefert die Daten, der Solver berechnet die L\xC3\xB6sung, und FreeCAD schreibt die Resultate wieder in die 3D-Welt.\n";
    return 0;
}
