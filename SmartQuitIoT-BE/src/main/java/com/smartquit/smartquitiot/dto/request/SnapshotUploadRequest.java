package com.smartquit.smartquitiot.dto.request;

import java.util.List;
import lombok.Data;

@Data
public class SnapshotUploadRequest {
  List<String> imageUrls;
}
