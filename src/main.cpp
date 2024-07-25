#include "webcam.hpp"
#include <iostream>

// Test branch "Windows"
// Test branch "Windows 2"

int main() {
  // On stock toutes les webcam
  std::vector<webcam::Info> webcams = webcam::getWebcamsInfo();
  webcam::UniqueId current_webcam_id;

  // On affiche le nom et l'ID de chaque webcam
  if (!webcams.empty()) {
    for (const auto &webcam : webcams) {
      std::cout << "\n";
      std::cout << "Webcam: " << webcam.name << "\n";
      std::cout << "Unique ID: " << webcam.unique_id.getDevicePath() << "\n";
      std::cout << "\n";
    }
  }

  // Choisir une webcam parmi celles disponibles (à adapter selon vos besoins)
  std::cout << "Choix de la webcam (Unique ID) : ";
  std::string webcam_id;
  std::cin >> webcam_id;

  for (const auto &webcam : webcams) {
    if (webcam.unique_id.getDevicePath() == webcam_id) {
      current_webcam_id = webcam.unique_id;
      std::cout << "Webcam: " << webcam.name << "\n";

      std::cout << "Available Resolutions: " << "\n";
      for (const auto &resolution : webcam.available_resolutions) {
        std::cout << "  " << resolution.width << "x" << resolution.height
                  << "\n";
      }
      std::cout << "Pixel Formats: " << "\n";
      for (const auto &format : webcam.pixel_formats) {
        std::cout << "  " << format << "\n";
      }
      break;
    }
  }

  // Utilisation de la Webcam gardée. => Générer une capture via l'ID unique de la caméra
  webcam::Capture capture(current_webcam_id);
  // TODO
  return 0;
}
