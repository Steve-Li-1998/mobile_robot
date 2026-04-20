FROM mathworks/matlab:r2024a

# Build-time customization for preinstalling MATLAB products.
# Example:
# docker compose build --build-arg MATLAB_PRODUCT_LIST="MATLAB Simulink Robotics_System_Toolbox" matlab
ARG MATLAB_RELEASE=R2024a
ARG MATLAB_PRODUCT_LIST="MATLAB Simulink Computer_Vision_Toolbox Control_System_Toolbox Curve_Fitting_Toolbox Image_Processing_Toolbox Optimization_Toolbox Robotics_System_Toolbox ROS_Toolbox Statistics_and_Machine_Learning_Toolbox Symbolic_Math_Toolbox"
ARG MPM_ADDITIONAL_FLAGS=""

USER root

# mpm is used by MathWorks reference Dockerfiles to install MATLAB products.
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN set -e; \
    wget -q https://www.mathworks.com/mpm/glnxa64/mpm; \
    chmod +x mpm; \
    if ! HOME=/home/matlab ./mpm install \
        --release=${MATLAB_RELEASE} \
        --destination=/opt/matlab/${MATLAB_RELEASE} \
        --products ${MATLAB_PRODUCT_LIST} \
        ${MPM_ADDITIONAL_FLAGS}; then \
        if [ -f /tmp/mathworks_root.log ] && grep -qi "already installed\|ExistingProduct" /tmp/mathworks_root.log; then \
            echo "Requested MATLAB products are already present; continuing build."; \
        else \
            echo "MPM installation failed. /tmp/mathworks_root.log:"; \
            [ -f /tmp/mathworks_root.log ] && cat /tmp/mathworks_root.log; \
            exit 1; \
        fi; \
    fi; \
    rm -f mpm /tmp/mathworks_root.log

USER matlab
