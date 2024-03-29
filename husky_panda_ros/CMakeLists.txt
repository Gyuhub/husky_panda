cmake_minimum_required(VERSION 3.10)
project(husky_panda_ros)

set(CMAKE_CXX_STANDARD 17)
find_package(Eigen3 REQUIRED 3.3)

set(PACKAGE_DEPENDENCIES
        rosbag
        husky_panda_control
        sensor_msgs
        std_msgs
        roscpp
        message_generation)

find_package(catkin REQUIRED COMPONENTS ${PACKAGE_DEPENDENCIES})

# Messages
add_message_files(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/msg
        FILES Array.msg Config.msg Rollout.msg Data.msg)
generate_messages(DEPENDENCIES std_msgs)

catkin_package(
        LIBRARIES ${PROJECT_NAME}
        INCLUDE_DIRS include
        CATKIN_DEPENDS ${PACKAGE_DEPENDENCIES} message_runtime)

set(COMMON_LIBRARIES ${catkin_LIBRARIES})
set(SYSTEM_INCLUDE_DIRECTORIES ${EIGEN3_INCLUDE_DIRS} ${catkin_INCLUDE_DIRS})

include_directories(include SYSTEM ${SYSTEM_INCLUDE_DIRECTORIES})


# Libraries
add_library(husky_panda_threading src/threading/Rate.cpp src/threading/Worker.cpp src/threading/WorkerManager.cpp)


add_library(${PROJECT_NAME}
        src/controller_interface.cpp
        src/conversions.cpp
        src/ros_params.cpp )
add_dependencies(${PROJECT_NAME} ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS} husky_panda_threading)
target_link_libraries(${PROJECT_NAME} ${COMMON_LIBRARIES} husky_panda_threading)

catkin_install_python(PROGRAMS scripts/plot_experiment.py scripts/record_data.py
        DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
        )
