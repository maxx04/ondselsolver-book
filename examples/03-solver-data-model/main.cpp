#include <iostream>
#include <string>
#include <vector>

struct PartData {
    std::string id;
    double x;
    double y;
    double z;
};

struct JointData {
    std::string type;
    std::string partA;
    std::string partB;
    double value;
};

int main() {
    std::vector<PartData> parts = {
        {"base", 0.0, 0.0, 0.0},
        {"arm", 2.0, 0.0, 0.0},
    };

    std::vector<JointData> joints = {
        {"revolute", "base", "arm", 90.0},
    };

    std::cout << "Teile:\n";
    for (const auto& part : parts) {
        std::cout << " - " << part.id << ": (" << part.x << ", " << part.y << ", " << part.z << ")\n";
    }

    std::cout << "\nJoints:\n";
    for (const auto& joint : joints) {
        std::cout << " - Typ: " << joint.type << ", " << joint.partA << " <-> " << joint.partB
                  << ", Wert: " << joint.value << "\n";
    }

    std::cout << "\nInterpretation: Diese Struktur ist die logische Repr\xC3\xA4sentation, die der Solver verarbeitet.\n";
    return 0;
}
