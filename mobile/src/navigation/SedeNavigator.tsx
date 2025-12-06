import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { SedeStackParamList } from '../types/navigation';
import { COLORS } from '../constants/colors';

// Placeholder screens - to be implemented
import { View, Text, StyleSheet } from 'react-native';

const SedeHomeScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>Sede Home - En desarrollo</Text>
  </View>
);

const MisUnidadesScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>Mis Unidades - En desarrollo</Text>
  </View>
);

const BitacoraUnidadSedeScreen = () => (
  <View style={styles.placeholder}>
    <Text style={styles.placeholderText}>Bitácora Unidad - En desarrollo</Text>
  </View>
);

const Stack = createStackNavigator<SedeStackParamList>();

export default function SedeNavigator() {
  return (
    <Stack.Navigator
      id="sede"
      screenOptions={{
        headerShown: false,
        cardStyle: { backgroundColor: COLORS.background },
      }}
    >
      <Stack.Screen
        name="SedeHome"
        component={SedeHomeScreen}
        options={{ title: 'Mi Sede' }}
      />
      <Stack.Screen
        name="MisUnidades"
        component={MisUnidadesScreen}
        options={{ title: 'Mis Unidades', headerShown: true }}
      />
      <Stack.Screen
        name="BitacoraUnidadSede"
        component={BitacoraUnidadSedeScreen}
        options={{ title: 'Bitácora', headerShown: true }}
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
