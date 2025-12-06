import React from 'react';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { MainDrawerParamList } from '../types/navigation';
import { useAuthStore } from '../store/authStore';
import BrigadaNavigator from './BrigadaNavigator';
import COPNavigator from './COPNavigator';
import SedeNavigator from './SedeNavigator';
import { COLORS } from '../constants/colors';

const Drawer = createDrawerNavigator<MainDrawerParamList>();

export default function MainDrawer() {
  const { usuario } = useAuthStore();

  if (!usuario) {
    return null;
  }

  const rol = usuario.rol;

  return (
    <Drawer.Navigator
      id="main"
      screenOptions={{
        headerStyle: {
          backgroundColor: COLORS.primary,
        },
        headerTintColor: '#fff',
        drawerActiveTintColor: COLORS.primary,
        drawerInactiveTintColor: COLORS.text.secondary,
      }}
    >
      {/* BRIGADA screens */}
      {rol === 'BRIGADA' && (
        <Drawer.Screen
          name="BrigadaStack"
          component={BrigadaNavigator}
          options={{
            title: 'Inicio',
            drawerLabel: 'Inicio',
          }}
        />
      )}

      {/* COP screens */}
      {(rol === 'COP' || rol === 'OPERACIONES' || rol === 'MANDOS' || rol === 'ADMIN') && (
        <Drawer.Screen
          name="COPStack"
          component={COPNavigator}
          options={{
            title: 'Centro de Operaciones',
            drawerLabel: 'COP',
          }}
        />
      )}

      {/* ENCARGADO_SEDE screens */}
      {rol === 'ENCARGADO_SEDE' && (
        <Drawer.Screen
          name="SedeStack"
          component={SedeNavigator}
          options={{
            title: 'Mi Sede',
            drawerLabel: 'Inicio',
          }}
        />
      )}
    </Drawer.Navigator>
  );
}
