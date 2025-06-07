import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

const UserMenu = ({ onProfile, onLogout }) => {
  const [open, setOpen] = React.useState(false);
  return (
    <View style={styles.menuWrapper}>
      <TouchableOpacity onPress={() => setOpen(o => !o)} style={styles.menuButton}>
        <Text style={styles.menuText}>☰</Text>
      </TouchableOpacity>
      {open && (
        <View style={styles.dropdown}>
          <TouchableOpacity onPress={onProfile} style={styles.dropdownItem}>
            <Text style={styles.dropdownText}>Profile</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={onLogout} style={styles.dropdownItem}>
            <Text style={styles.dropdownText}>Logout</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  menuWrapper: {
    position: 'relative',
    marginRight: 16,
  },
  menuButton: {
    padding: 8,
  },
  menuText: {
    fontSize: 22,
    color: '#3b82f6',
    fontWeight: 'bold',
  },
  dropdown: {
    position: 'absolute',
    top: 36,
    left: 0,
    backgroundColor: '#fff',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
    zIndex: 10,
  },
  dropdownItem: {
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  dropdownText: {
    fontSize: 16,
    color: '#222',
  },
});

export default UserMenu;
