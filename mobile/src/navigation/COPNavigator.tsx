import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { COPStackParamList } from '../types/navigation';
import { COLORS } from '../constants/colors';
import COPMapaScreen from '../screens/cop/COPMapaScreen';

// Placeholder screens - to be implemented
import { View, Text, StyleSheet } from 'react-native';

const COPHomeScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>COP Home - En desarrollo</Text>
  </View>
);

const BitacoraUnidadScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>Bitácora Unidad - En desarrollo</Text>
  </View>
);

const DetalleSituacionCOPScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>Detalle Situación - En desarrollo</Text>
  </View>
);

const GestionGruposScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>Gestión de Grupos - En desarrollo</Text>
  </View>
);

const GestionMovimientosScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>Gestión de Movimientos - En desarrollo</Text>
  </View>
);

const Stack = createStackNavigator<COPStackParamList>();

export default function COPNavigator() {
  return (
    <Stack.Navigator
      id="cop"
      screenOptions={{
        headerShown: false,
        cardStyle: { backgroundColor: COLORS.background },
      }}
    >
      <Stack.Screen
        name="COPHome"
        component={COPHomeScreen}
        options={{ title: 'COP' }}
      />
      <Stack.Screen
        name="MapaUnidades"
        component={COPMapaScreen}
        options={{ title: 'Mapa', headerShown: true }}
      />
      <Stack.Screen
        name="BitacoraUnidad"
        component={BitacoraUnidadScreen}
        options={{ title: 'Bitácora Unidad', headerShown: true }}
      />
      <Stack.Screen
        name="DetalleSituacionCOP"
        component={DetalleSituacionCOPScreen}
        options={{ title: 'Detalle', headerShown: true }}
      />
      <Stack.Screen
        name="GestionGrupos"
        component={GestionGruposScreen}
        options={{ title: 'Gestión de Grupos', headerShown: true }}
      />
      <Stack.Screen
        name="GestionMovimientos"
        component={GestionMovimientosScreen}
        options={{ title: 'Movimientos', headerShown: true }}
      />
    </Stack.Navigator>
  );
}

const styles = StyleSheet.create({
  placeholder: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
  },
  placeholderText: {
    fontSize: 18,
    color: COLORS.text.secondary,
  },
});
