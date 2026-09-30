#include "ASMTAssembly.h"
#include "ASMTConstantGravity.h"
#include "ASMTJoint.h"
#include "ASMTPart.h"
#include "ASMTRevoluteJoint.h"
#include "ASMTSimulationParameters.h"

#include <filesystem>
#include <iostream>
#include <stdexcept>
#include <string>

namespace {
void require(bool condition, const std::string& message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

void inspect(const MbD::ASMTAssembly& assembly) {
    std::cout << "Parts: " << assembly.parts->size() << '\n';
    for (const auto& part : *assembly.parts) {
        std::cout << "Part: " << part->name << '\n';
    }

    std::cout << "Joints: " << assembly.joints->size() << '\n';
    for (const auto& joint : *assembly.joints) {
        std::cout << "Joint: " << joint->name << " ["
                  << joint->markerI << " -> " << joint->markerJ << "]\n";
    }
}
}

int main(int argc, char* argv[]) {
    const std::string mode = argc > 1 ? argv[1] : "inspect";
    const std::filesystem::path inputPath = argc > 2 ? argv[2] : DEFAULT_ASMT_FILE;

    try {
        auto assembly = MbD::ASMTAssembly::assemblyFromFile(inputPath.string());

        if (mode == "inspect") {
            inspect(*assembly);
            return 0;
        }

        if (mode == "part-api") {
            const auto previousPartCount = assembly->parts->size();
            auto part = MbD::ASMTPart::With();
            part->setName("ApiDemoPart");
            part->setPosition3D(0.0, 0.0, 25.0);
            part->setRotationMatrix(
                1.0, 0.0, 0.0,
                0.0, 1.0, 0.0,
                0.0, 0.0, 1.0);
            part->principalMassMarker->setMass(2.0);
            part->principalMassMarker->setMomentOfInertias(1.0, 1.0, 1.0);
            assembly->addPart(part);
                require(assembly->parts->size() == previousPartCount + 1,
                    "Part wurde nicht zur Assembly hinzugefügt.");
                require(part->owner == assembly.get(), "Part-Owner wurde nicht gesetzt.");
                std::cout << "Part-API und Owner-Verknüpfung geprüft: " << part->name << '\n';
            return 0;
        }

            if (mode == "joint-api") {
            require(!assembly->joints->empty(), "Fixture enthält keinen Joint als Markerbeispiel.");
            const auto previousJointCount = assembly->joints->size();
            const auto markerI = assembly->joints->front()->markerI;
            const auto markerJ = assembly->joints->front()->markerJ;
            require(!markerI.empty() && !markerJ.empty(), "Fixture-Joint hat leere Markerpfade.");

            auto joint = MbD::ASMTRevoluteJoint::With();
            joint->setName("ApiDemoRevolute");
            joint->setMarkerI(markerI);
            joint->setMarkerJ(markerJ);
            assembly->addJoint(joint);
                require(assembly->joints->size() == previousJointCount + 1,
                    "Joint wurde nicht zur Assembly hinzugefügt.");
                require(joint->owner == assembly.get(), "Joint-Owner wurde nicht gesetzt.");
                require(joint->markerI == markerI && joint->markerJ == markerJ,
                    "Joint-Markerpfade wurden nicht übernommen.");
                std::cout << "Joint-API und Owner-Verknüpfung geprüft.\n";
            std::cout << "Marker I/J: " << markerI << " -> " << markerJ << '\n';
            return 0;
        }

        if (mode == "settings-api") {
            auto parameters = MbD::ASMTSimulationParameters::With();
            parameters->settstart(0.0);
            parameters->settend(0.25);
            parameters->sethmin(1.0e-8);
            parameters->sethmax(0.01);
            parameters->sethout(0.005);
            parameters->seterrorTol(1.0e-6);
            parameters->setmaxIter(20);
            assembly->setSimulationParameters(parameters);
                auto gravity = MbD::ASMTConstantGravity::With();
                gravity->setg(0.0, 0.0, -9.81);
                assembly->setConstantGravity(gravity);
                require(assembly->simulationParameters == parameters,
                    "Simulationsparameter wurden nicht an die Assembly gebunden.");
                require(parameters->owner == assembly.get(), "Parameter-Owner wurde nicht gesetzt.");
                require(gravity->owner == assembly.get(), "Gravity-Owner wurde nicht gesetzt.");
                require(parameters->tend == 0.25 && parameters->hmax == 0.01,
                    "Die Simulationsparameter wurden nicht übernommen.");
                std::cout << "Simulationsparameter und konstante Gravitation gesetzt.\n";
            return 0;
        }

        throw std::invalid_argument(
                "Modus muss inspect, part-api, joint-api oder settings-api sein.");
    } catch (const std::exception& error) {
        std::cerr << "OndselSolver-API-Beispiel fehlgeschlagen: " << error.what() << '\n';
        return 1;
    }
}
