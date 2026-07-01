double calculateWaterIntake({
  required double weight,
  required int age,
}) {
  double base = weight * 0.033;

  if (age >= 31 && age <= 55) {
    base *= 0.95;
  } else if (age > 55) {
    base *= 0.9;
  }

  return base;
}

