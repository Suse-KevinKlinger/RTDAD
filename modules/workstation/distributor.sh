for ((i = 2; i <= 8; i++)); do
  scp /etc/pki/trust/anchors/Harbor-Registry.example.com.crt 192.168.180.8$i:/etc/pki/trust/anchors/Harbor-Registry.example.com.crt
done
