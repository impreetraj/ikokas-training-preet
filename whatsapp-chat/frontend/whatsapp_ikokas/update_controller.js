const fs = require('fs');
const path = 'p:/flutter project/whatsapp-chat/backend/controllers/messageController.js';
let content = fs.readFileSync(path, 'utf8');

const newSendMessage = \const sendMessage = async (req, res) => {
  const { phone, message, type = 'text', mediaId, location } = req.body;
  if (!phone) return res.status(400).json({ error: 'Phone required' });

  try {
    let payload = {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to: phone,
      type: type,
    };

    if (type === 'text') {
      if (!message) return res.status(400).json({ error: 'Message required for text type' });
      payload.text = { preview_url: false, body: message };
    } else if (['image', 'video', 'audio', 'document'].includes(type)) {
      if (!mediaId) return res.status(400).json({ error: 'mediaId required for media type' });
      payload[type] = { id: mediaId };
    } else if (type === 'location') {
      if (!location || !location.latitude || !location.longitude) return res.status(400).json({ error: 'latitude and longitude required for location' });
      payload.location = {
        latitude: location.latitude,
        longitude: location.longitude,
        name: location.name || "Location",
        address: location.address || ""
      };
    }

    const response = await axios.post(
      \\\https://graph.facebook.com/v19.0/\/messages\\\,
      payload,
      {
        headers: { Authorization: \\\Bearer \\\\ }
      }
    );

    const messageId = response.data.messages[0].id;
    const newMessage = await Message.create({
      messageId,
      senderPhone: process.env.MY_PHONE_NUMBER,
      receiverPhone: phone,
      textContent: message,
      type: type,
      mediaId: mediaId,
      location: location ? { lat: location.latitude, long: location.longitude, name: location.name, address: location.address } : undefined,
      status: 'sent',
      timestamp: new Date()
    });

    res.status(200).json({ success: true, data: newMessage });
  } catch (error) {
    console.error(error.response?.data || error.message);
    res.status(500).json({ error: 'Failed to send message', details: error.response?.data });
  }
};\;

content = content.replace(/const sendMessage = async.*?res\.status\(500\)\.json\({ error: 'Failed to send message' }\);\s*}\s*};/s, newSendMessage);
fs.writeFileSync(path, content);
console.log('Updated messageController.js');
