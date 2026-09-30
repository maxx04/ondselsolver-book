#include <cmath>
#include <iomanip>
#include <iostream>
#include <string>

struct Part {
    std::string name;
    double x;
    double y;
    double z;
};

struct DistanceConstraint {
    std::string partA;
    std::string partB;
    double targetDistance;
};

static double distance(const Part& a, const Part& b) {
    const double dx = b.x - a.x;
    const double dy = b.y - a.y;
    const double dz = b.z - a.z;
    return std::sqrt(dx * dx + dy * dy + dz * dz);
}

int main() {
    Part a{"A", 0.0, 0.0, 0.0};
    Part b{"B", 3.0, 0.0, 0.0};
    DistanceConstraint constraint{"A", "B", 5.0};

    const double actual = distance(a, b);
    const double residual = actual - constraint.targetDistance;

    std::cout << "Teil A: (" << a.x << ", " << a.y << ", " << a.z << ")\n";
    std::cout << "Teil B: (" << b.x << ", " << b.y << ", " << b.z << ")\n";
    std::cout << "Aktueller Abstand: " << std::setprecision(6) << actual << "\n";
    std::cout << "Zielabstand: " << constraint.targetDistance << "\n";
    std::cout << "Residual: " << residual << "\n";

    std::cout << "\nInterpretation: Der Solver versucht, residual gegen 0 zu bringen.\n";
    return 0;
}
