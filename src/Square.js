import React from 'react';

function Square({ value, onClick }) {

     const squareStyle = {
    backgroundColor: value === '#' ? 'black' : 'white', // Cambia el color del fondo a negro si el valor es '#', de lo contrario, blanco
    color: 'black', // Color del texto
    fontSize: '24px', // Tamaño de la fuente
    fontWeight: 'bold', // Peso de la fuente
    border: '1px solid #999', // Borde
    padding: '0', // Espaciado interno
    textAlign: 'center' // Alineación del texto
  };

    return (
        <button style={squareStyle} onClick={onClick}>
            {value !== '_' ? value : null}
        </button>
    );
}

export default Square;