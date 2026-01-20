package com.smartquit.smartquitiot.repository;

import com.smartquit.smartquitiot.entity.NewsMedia;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NewsMediaRepository extends JpaRepository<NewsMedia, Integer> {

  List<NewsMedia> findByNewsId(Integer id);
}
