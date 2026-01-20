package com.smartquit.smartquitiot.repository;

import com.smartquit.smartquitiot.entity.InterestCategory;
import java.util.List;
import java.util.Set;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterestCategoryRepository extends JpaRepository<InterestCategory, Integer> {
  List<InterestCategory> findByNameIn(Set<String> newInterestNames);
}
