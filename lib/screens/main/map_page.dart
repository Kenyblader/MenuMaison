import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:menu_maison/utils/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.function}) : super(key: key);
  final Function(String) function;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  LatLng? currentPosition;
  List<LatLng> savedPositions = [];
  bool isLoading = true;
  final double defaultZoom = 15.0;
  // La position actuellement sélectionnée
  LatLng? temporarySelectedPosition;

  // Contrôleur pour gérer l'animation du panneau du bas
  final DraggableScrollableController footerController =
      DraggableScrollableController();
  bool isFooterVisible = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Fonction pour charger les positions sauvegardées depuis SharedPreferences

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    // Vérification et demande des permissions de localisation
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La permission de localisation est nécessaire'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Les permissions de localisation sont définitivement refusées, veuillez les activer dans les paramètres',
          ),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la récupération de la position: $e'),
        ),
      );
      // Position par défaut si la géolocalisation échoue (Paris)
      setState(() {
        currentPosition = LatLng(48.8566, 2.3522);
        isLoading = false;
      });
    }
  }

  // Fonction pour télécharger la région autour de la position actuelle
  Future<void> _downloadCurrentRegion() async {
    // Demande de permission de stockage pour Android
    if (await Permission.storage.request().isGranted) {
      try {
        final region = CircleRegion(
          currentPosition as LatLng,
          const Distance(roundResult: false).distance(
                currentPosition as LatLng,
                LatLng(1, 1), // Edge coordinate
              ) /
              1000, // Convert to kilometers
        );

        // Démarrage du téléchargement
        const FMTCStore('mapStore').download.startForeground(
          region: region.toDownloadable(
            minZoom: 10,
            maxZoom: 10,
            options: TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement de la région: $e'),
          ),
        );
      }
    }
  }

  // Fonction pour gérer le tap sur la carte
  void _handleMapTap(TapPosition tapPosition, LatLng tappedPoint) {
    setState(() {
      temporarySelectedPosition = tappedPoint;
      isFooterVisible = true;
    });
  }

  // Fonction pour confirmer la sélection de la position
  void _confirmSelectedPosition() {
    if (temporarySelectedPosition != null) {
      setState(() {
        savedPositions.add(temporarySelectedPosition!);
      });
      // _saveSavedPositions();
      Location.choice = temporarySelectedPosition as LatLng;
      widget.function(temporarySelectedPosition.toString());
      // Retour à la page précédente
      Navigator.of(context).pop(temporarySelectedPosition);
    }
  }

  // Fonction pour afficher la liste des positions sauvegardées
  void _showSavedLocationsList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Positions sauvegardées'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: savedPositions.length,
              itemBuilder: (context, index) {
                final position = savedPositions[index];
                return ListTile(
                  title: Text('Position ${index + 1}'),
                  subtitle: Text(
                    'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    mapController.move(position, defaultZoom);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        savedPositions.removeAt(index);
                      });
                      // _saveSavedPositions();
                      Navigator.of(context).pop();
                      _showSavedLocationsList(); // Réouvre la liste mise à jour
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher les options d'un marqueur sauvegardé
  void _showSavedPositionOptions(LatLng position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Position sauvegardée'),
          content: Text(
            'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  savedPositions.remove(position);
                });
                // _saveSavedPositions();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Position supprimée')),
                );
              },
              child: const Text('Supprimer'),
            ),
            TextButton(
              onPressed: () {
                mapController.move(position, defaultZoom);
                Navigator.of(context).pop();
              },
              child: const Text('Centrer la carte'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _tileProvider = FMTCTileProvider(
      stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte avec mise en cache'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadCurrentRegion,
            tooltip: 'Télécharger la région actuelle',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentPosition!,
                  initialZoom: defaultZoom,
                  maxZoom: 18.0,
                  minZoom: 5.0,
                  onTap: _handleMapTap,
                ),
                children: [
                  // Utilisation de TileLayer avec le système de cache
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    // Configuration du cache des tuiles
                    tileProvider: _tileProvider,
                  ),
                  // Marqueurs pour la position actuelle et positions sauvegardées
                  MarkerLayer(
                    markers: [
                      // Marqueur pour la position actuelle
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: currentPosition!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                      // Marqueurs pour les positions sauvegardées
                      ...savedPositions
                          .map(
                            (position) => Marker(
                              width: 40.0,
                              height: 40.0,
                              point: position,
                              child: GestureDetector(
                                onTap:
                                    () => _showSavedPositionOptions(position),
                                child: const Icon(
                                  Icons.place,
                                  color: Colors.blue,
                                  size: 40.0,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                  if (isFooterVisible && temporarySelectedPosition != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Indicateur de glissement
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // Informations sur la position sélectionnée
                            Text(
                              'Position sélectionnée',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Latitude: ${temporarySelectedPosition!.latitude.toStringAsFixed(6)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Longitude: ${temporarySelectedPosition!.longitude.toStringAsFixed(6)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            // Boutons d'action
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      temporarySelectedPosition = null;
                                      isFooterVisible = false;
                                    });
                                  },
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: _confirmSelectedPosition,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (savedPositions.isNotEmpty) {
                _showSavedLocationsList();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aucune position sauvegardée')),
                );
              }
            },
            heroTag: 'savedLocations',
            child: const Icon(Icons.bookmark),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              if (currentPosition != null) {
                mapController.move(currentPosition!, defaultZoom);
              }
            },
            heroTag: 'myLocation',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
