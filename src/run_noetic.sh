#!/bin/bash
SESSION_NAME="AGRNav"

# Get the workspace root directory (assuming script is in src/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create a new tmux session
tmux new-session -d -s "$SESSION_NAME"

# Window 0: Planning and simulation (C++ nodes, uses system Python 3.8)
tmux send-keys -t "$SESSION_NAME:0" "source /opt/ros/noetic/setup.bash && source $SCRIPT_DIR/devel/setup.bash && roslaunch plan_manage kino_replan.launch" C-m

# Window 1: Point cloud listener (Python without PyTorch, uses system Python 3.8)
tmux new-window -t "$SESSION_NAME" "sleep 2; source /opt/ros/noetic/setup.bash && source $SCRIPT_DIR/devel/setup.bash && roslaunch perception pointcloud_listener.launch"

# Window 2: SCONet inference (Python with PyTorch, uses micromamba environment)
tmux new-window -t "$SESSION_NAME" "sleep 4; source /opt/ros/noetic/setup.bash && source $SCRIPT_DIR/devel/setup.bash && roslaunch perception inference.launch"

# Attach to the tmux session
tmux attach-session -t "$SESSION_NAME"
