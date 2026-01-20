package com.smartquit.smartquitiot.dto.request;

import com.smartquit.smartquitiot.enums.NewsStatus;
import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateNewsRequest {

  String title;
  String content;
  String thumbnailUrl;
  List<String> mediaUrls;
  NewsStatus newsStatus;
}
