set -e

INSTALL_DIR="/opt/twamp"
SYSTEMD_DIR="/etc/systemd/system"

TCPECHO_BIN="tcpecho_ipv6-1"
TWAMPY_BIN="twampy"

TCPECHO_SERVICE="tcpecho_ipv6-1.service"
TWAMPY_SERVICE="twampy.service"

echo "Creating directory $INSTALL_DIR if it does not exist..."
sudo mkdir -p "$INSTALL_DIR"

echo "Copying binaries to $INSTALL_DIR..."
sudo cp "./$TCPECHO_BIN" "$INSTALL_DIR/"
sudo cp "./$TWAMPY_BIN" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/$TCPECHO_BIN"
sudo chmod +x "$INSTALL_DIR/$TWAMPY_BIN"

echo "Copying service files to $SYSTEMD_DIR..."
sudo cp "./$TCPECHO_SERVICE" "$SYSTEMD_DIR/"
sudo cp "./$TWAMPY_SERVICE" "$SYSTEMD_DIR/"

echo "Updating $TCPECHO_SERVICE ExecStart and WorkingDirectory..."
sudo sed -i "s|^ExecStart=.*|ExecStart=$INSTALL_DIR/$TCPECHO_BIN|" "$SYSTEMD_DIR/$TCPECHO_SERVICE"
sudo sed -i "s|^WorkingDirectory=.*|WorkingDirectory=$INSTALL_DIR|" "$SYSTEMD_DIR/$TCPECHO_SERVICE"

echo "Updating $TWAMPY_SERVICE ExecStart and WorkingDirectory..."
# Note: Use straight quotes in sed and be careful with special characters
sudo sed -i "s|^ExecStart=.*|ExecStart=$INSTALL_DIR/$TWAMPY_BIN responder \"[::]:868\" --padding 512|" "$SYSTEMD_DIR/$TWAMPY_SERVICE"
sudo sed -i "s|^WorkingDirectory=.*|WorkingDirectory=$INSTALL_DIR|" "$SYSTEMD_DIR/$TWAMPY_SERVICE"

echo "Reloading systemd daemon..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "Enabling and starting $TCPECHO_SERVICE..."
sudo systemctl enable "$TCPECHO_SERVICE"
sudo systemctl start "$TCPECHO_SERVICE"

echo "Enabling and starting $TWAMPY_SERVICE..."
sudo systemctl enable "$TWAMPY_SERVICE"
sudo systemctl start "$TWAMPY_SERVICE"

echo "Setup completed successfully!"
