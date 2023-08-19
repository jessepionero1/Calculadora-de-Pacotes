import 'box_dimensions.dart';

class BoxCalculator {
  BoxDimensions smallBox = BoxDimensions(height: 159, length: 159, width: 295);
  BoxDimensions mediumBox = BoxDimensions(height: 209, length: 299, width: 299);
  BoxDimensions largeBox = BoxDimensions(height: 254, length: 349, width: 427);

  double spacePercentage =
      0.25; // deixamos um 25 % libre para que os pacotes nao fiquem apertados

  int calculatePackageCapacity(BoxDimensions package, BoxDimensions box) {
    double packageVolume = package.volume;

    if (packageVolume <= 0) {
      return 0;
    }

    double boxVolume = box.volume;
    double availableVolume = boxVolume * (1 - spacePercentage);
    int numberOfPackages = (availableVolume / packageVolume).floor();

    return numberOfPackages;
  }
}
