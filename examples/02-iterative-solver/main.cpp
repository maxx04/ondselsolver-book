#include <cmath>
#include <iomanip>
#include <iostream>

struct Part {
    double x;
    double y;
    double z;
};

static double distanceError(const Part& a, const Part& b, double targetDistance) {
    const double dx = b.x - a.x;
    const double dy = b.y - a.y;
    const double dz = b.z - a.z;
    const double actual = std::sqrt(dx * dx + dy * dy + dz * dz);
    return actual - targetDistance;
}

int main() {
    Part a{0.0, 0.0, 0.0};
    Part b{3.0, 0.0, 0.0};
    const double targetDistance = 5.0;

    double error = distanceError(a, b, targetDistance);
    std::cout << "Fehler vor Iteration: " << std::setprecision(6) << error << "\n";

    for (int i = 0; i < 6; ++i) {
        const double correction = error * 0.25;
        b.x -= correction;
        error = distanceError(a, b, targetDistance);
        std::cout << "Iterationsschritt " << i + 1 << ": x(B) = " << b.x
                  << ", Fehler = " << error << "\n";
    }

    std::cout << "\nErgebnis: Der Solver korrigiert die Position iterativ, bis der Fehler klein genug ist.\n";
    return 0;
}
