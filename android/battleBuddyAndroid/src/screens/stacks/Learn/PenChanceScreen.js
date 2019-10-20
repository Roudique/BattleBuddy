import React from 'react';
import styled from 'styled-components/native';

const ScrollView = styled.ScrollView`
  background: ${({theme}) => theme.colors.background};
`;

const PenChanceScreen = () => {
  return <ScrollView></ScrollView>;
};

PenChanceScreen.navigationOptions = {
  title: 'Penetration Chance'
};

export default PenChanceScreen;
