import React from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import AppNavigator from './src/navigation/AppNavigator';
import { TestModeProvider } from './src/context/TestModeContext';

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <TestModeProvider>
          <StatusBar style="light" />
          <AppNavigator />
        </TestModeProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
