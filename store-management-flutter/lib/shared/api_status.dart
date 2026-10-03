import 'package:get/get.dart';
import 'app_feedback.dart';

abstract class ApiStatus {
  static checkStatus(dynamic response) {
    if (response.statusCode == 400) {
      return AppFeedback.error("Bad request", title: "Request failed");
    } else if (response.statusCode == 401) {
      return AppFeedback.error("Unauthorized request", title: "Request failed");
    } else if (response.statusCode == 403) {
      return AppFeedback.error("Unauthorized request", title: "Request failed");
    } else if (response.statusCode == 404) {
      return AppFeedback.error("Page not found", title: "Request failed");
    } else if (response.statusCode == 408){
       return AppFeedback.error("Request Time-out", title: "Request failed");
    } else if (response.statusCode == 415){
       return AppFeedback.error("Unsupported Media Type", title: "Request failed");
    } else if (response.statusCode >= 500 ){
       return AppFeedback.error("Server Error", title: "Request failed");
    }
  }
}
