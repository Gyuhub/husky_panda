/*!
 * @file     expert_imp.h
 * @author   Etienne Walther
 * @date     08.12.2020
 * @version  1.0
 * @brief    description
 */

#pragma once

#include "husky_panda_control/tree_search/experts/expert_base.h"

namespace husky_panda_control {

class ImpExp : public ExpertBase {
 public:
  ImpExp(char short_name, config_t config, dynamics_ptr dynamics)
      : ExpertBase(short_name, config, dynamics),
        expert_sampler_one_(dynamics_->get_input_dimension()) {
    expert_sampler_one_.set_covariance(config_.input_variance);

    mean_.clear();
    for (int step = 0; step < std::floor(config_.horizon / config_.step_size);
         ++step) {
      expert_sampler_map_[step] = expert_sampler_one_;
      mean_.push_back(Eigen::VectorXd::Zero(dynamics_->get_input_dimension()));
    }
    std::cout << "Created expert ImpExp" << std::endl;
  }

  ~ImpExp() = default;

  Eigen::VectorXd get_sample(size_t step) override {
    return mean_[step] + expert_sampler_map_[step].get_sample();
  }

  Eigen::MatrixXd get_sigma_inv(size_t step) override {
    return expert_sampler_map_[step].sigma_inv();
  }

  void update_expert(std::vector<Eigen::VectorXd> mean) override {
    for (long unsigned int step = 0; step < mean.size(); ++step) {
      mean_[step] = mean[step];
    }
  }

 protected:
  husky_panda_control::GaussianSampler expert_sampler_one_;
  std::map<size_t, husky_panda_control::GaussianSampler> expert_sampler_map_;

  std::vector<Eigen::VectorXd> mean_;
};
}  // namespace husky_panda_control
