import 'box_dimensions.dart';

// Define la clase BoxCalculator.
class BoxCalculator {
  // Define las dimensiones predeterminadas de tres tipos de cajas: pequeña, mediana y grande.
  BoxDimensions smallBox = BoxDimensions(height: 159, length: 159, width: 295);
  BoxDimensions mediumBox = BoxDimensions(height: 209, length: 299, width: 299);
  BoxDimensions largeBox = BoxDimensions(height: 254, length: 349, width: 427);

  // Define un porcentaje de espacio que se deja libre en cada caja.
  // En este caso, es del 25% para evitar que los paquetes queden demasiado apretados.
  double spacePercentage = 0.25;

  // Esta función calcula la capacidad de una caja, es decir, cuántos paquetes puede contener.
  int calculatePackageCapacity(BoxDimensions package, BoxDimensions box) {
    // Calcula el volumen del paquete.
    double packageVolume = package.volume;

    // Si el volumen del paquete es 0 o menor, devuelve 0.
    if (packageVolume <= 0) {
      return 0;
    }

    // Calcula el volumen total de la caja.
    double boxVolume = box.volume;

    // Calcula el volumen disponible en la caja teniendo en cuenta el porcentaje de espacio que se deja libre.
    double availableVolume = boxVolume * (1 - spacePercentage);

    // Calcula cuántos paquetes puede contener la caja basándose en el volumen disponible y el volumen del paquete.
    // La función floor() asegura que el resultado sea un número entero al redondear hacia abajo.
    int numberOfPackages = (availableVolume / packageVolume).floor();

    // Devuelve el número de paquetes que puede contener la caja.
    return numberOfPackages;
  }
}
