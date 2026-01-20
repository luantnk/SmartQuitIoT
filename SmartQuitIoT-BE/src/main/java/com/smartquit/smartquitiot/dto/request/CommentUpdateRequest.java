package com.smartquit.smartquitiot.dto.request;

import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommentUpdateRequest {
  private String content;
  private List<CommentCreateRequest.CommentMediaRequest> media;
}
