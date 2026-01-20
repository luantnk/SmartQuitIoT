package com.smartquit.smartquitiot.repository;

import com.smartquit.smartquitiot.entity.Metric;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MetricRepository extends JpaRepository<Metric, Integer> {

  Optional<Metric> findByMemberId(Integer memberId);
}
