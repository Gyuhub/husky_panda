//
// Created by giuseppe on 25.05.21.
//

#pragma once

#include "husky_panda_control/core/config.h"
#include "husky_panda_control/core/policy.h"
#include "husky_panda_control/policies/receding_horizon_spline.h"

/// Spline Policy in development state
namespace husky_panda_control {
class SplinePolicy : public Policy {
 public:
  SplinePolicy(int nu, const Config& config);

  Eigen::VectorXd nominal(double t) override;

  Eigen::VectorXd sample(double t, int k) override;

  Eigen::VectorXd get_time() { return policies_[0].get_time(); }

  void update_samples(const std::vector<double>& weights, const int keep) override;

  void update(const std::vector<double>& weights, const double step_size) override;

  void shift(const double t) override;

  void bound() override {}; // TODO(giuseppe)
 private:
  std::vector<RecedingHorizonSpline> policies_;
};
}  // namespace husky_panda_control
