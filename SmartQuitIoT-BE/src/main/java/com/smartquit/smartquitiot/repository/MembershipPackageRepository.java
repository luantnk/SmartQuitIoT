package com.smartquit.smartquitiot.repository;

import com.smartquit.smartquitiot.entity.MembershipPackage;
import com.smartquit.smartquitiot.enums.MembershipPackageType;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MembershipPackageRepository extends JpaRepository<MembershipPackage, Integer> {
  List<MembershipPackage> findByType(MembershipPackageType membershipPackageType);
}
