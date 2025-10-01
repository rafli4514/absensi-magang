import { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents, Circle } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Fix for default markers in React Leaflet
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

interface InteractiveMapProps {
  latitude: number;
  longitude: number;
  onLocationChange: (lat: number, lng: number) => void;
  height?: string;
  useRadius?: boolean;
  radius?: number; 
}

// Component for handling map clicks
function LocationMarker({ position, onLocationChange }: { 
  position: [number, number]; 
  onLocationChange: (lat: number, lng: number) => void;
}) {
  const [markerPosition, setMarkerPosition] = useState<[number, number]>(position);

  const map = useMapEvents({
    click(e) {
      const { lat, lng } = e.latlng;
      setMarkerPosition([lat, lng]);
      onLocationChange(lat, lng);
    },
  });

  useEffect(() => {
    setMarkerPosition(position);
    map.setView(position, map.getZoom());
  }, [position, map]);

  return (
    <Marker 
      position={markerPosition}
      draggable={true}
      eventHandlers={{
        dragend: (e) => {
          const marker = e.target;
          const position = marker.getLatLng();
          setMarkerPosition([position.lat, position.lng]);
          onLocationChange(position.lat, position.lng);
        },
      }}
    />
  );
}

export default function InteractiveMap({ 
  latitude, 
  longitude, 
  onLocationChange, 
  height = "300px",
  useRadius = false,
  radius = 0,
}: InteractiveMapProps) {
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  if (!isLoaded) {
    return (
      <div 
        className="flex items-center justify-center bg-gray-100 rounded-lg border border-gray-200"
        style={{ height }}
      >
        <div className="text-center text-gray-500">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-2"></div>
          <p className="text-sm">Memuat peta...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="relative rounded-lg overflow-hidden border border-gray-200">
      <MapContainer
        center={[latitude, longitude]}
        zoom={15}
        style={{ height, width: '100%' }}
        className="z-0"
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {/* Radius visualization */}
        {useRadius && (
          <Circle
            center={[latitude, longitude]}
            radius={radius}
            pathOptions={{ color: '#2563eb', fillColor: '#60a5fa', fillOpacity: 0.2 }}
          />
        )}
        <LocationMarker 
          position={[latitude, longitude]} 
          onLocationChange={onLocationChange}
        />
      </MapContainer>
      
      {/* Instructions Overlay */}
      <div className="absolute top-2 right-2 bg-white bg-opacity-90 rounded-lg p-2 shadow-lg z-10 ">
        <div className="text-xs text-gray-700">
          <p className="font-medium">🖱️ Klik pada peta untuk set lokasi</p>
          <p>📍 Drag marker untuk pindah posisi</p>
          {useRadius && (
            <p className="mt-1">🎯 Radius aktif: <span className="font-medium">{radius}m</span></p>
          )}
        </div>
      </div>
      
      {/* Coordinates Display */}
      <div className="absolute bottom-2 right-2 bg-white bg-opacity-90 rounded-lg p-2 shadow-lg z-10">
        <div className="text-xs text-gray-700">
          <p>📍 {latitude.toFixed(6)}</p>
          <p>🌍 {longitude.toFixed(6)}</p>
        </div>
      </div>
    </div>
  );
}
