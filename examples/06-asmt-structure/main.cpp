#include <iostream>
#include <string>
#include <vector>

struct Part {
    std::string name;
    double x;
    double y;
    double z;
};

struct Joint {
    std::string type;
    std::string partA;
    std::string partB;
    std::string axis;
};

int main() {
    std::vector<Part> parts = {
        {"Base", 0.0, 0.0, 0.0},
        {"Arm", 10.0, 0.0, 0.0},
    };

    std::vector<Joint> joints = {
        {"Revolute", "Base", "Arm", "Z"},
    };

    std::cout << "ASMT-ähnliche Struktur:\n";
    std::cout << "Assembly {\n";
    for (const auto& part : parts) {
        std::cout << "  Part { Name: " << part.name << ", Position: (" << part.x << ", " << part.y << ", " << part.z << ") }\n";
    }
    for (const auto& joint : joints) {
        std::cout << "  Joint { Type: " << joint.type << ", PartA: " << joint.partA << ", PartB: " << joint.partB << ", Axis: " << joint.axis << " }\n";
    }
    std::cout << "}\n\n";

    std::cout << "Interpretation: Das ist ein ASMT-ähnlicher Lese-/Datenkontext, nicht die komplette FreeCAD-API.\n";
    return 0;
}
