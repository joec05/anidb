/// Stores fixed text to display in an error snackbar, depending on the type of the error
class ErrorLabels {

  final title = "Error!!!";

  final unknown = "An unknown error occured";

  final api = "Server error";

  final searchTextMin = "Minimum 4 characters needed!!!";

  final invalidInput = "Invalid input!!!";

  final maxValueReached = "Maximum value reached!!!";
  
}

class SuccessLabels {

  final savedProgress = "Successfully saved progress";

  final deleteFromList = "Successfully deleted from list";
}

class WarningLabels {
}

final tWarning = WarningLabels();

final tErr = ErrorLabels();

final tSuccess = SuccessLabels();