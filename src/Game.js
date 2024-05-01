import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import Toggle from './Toggle';

let pengine;

function Game() {

  // State
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [toggled, setToggled] = useState(false);
  const [rowCluesSat, setRowCluesSat] = useState([]);
  const [colCluesSat, setColCluesSat] = useState([]);
  const [win, setWin] = useState(false);

  const handleToggle = () => {
    setToggled(!toggled);
  }

  useEffect(() => {
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
    
  }, []);
  
  function handleServerReady(instance) {
    pengine = instance;
    const queryS = `init(RowClues, ColumClues, Grid)`;
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setRowCluesSat([...response['RowClues']].fill(false));
        setColCluesSat([...response['ColumClues']].fill(false));
        
        
        
      }
    });
  }

  useEffect(() => {
    
      checkInitial(rowsClues, colsClues, grid);
  },[rowsClues, colsClues]);

  function checkInitial(rowsClues, colsClues, grid){
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",,,,],["X",,"X",,],["X",,,,],["#","#","#",,],[,_,"#","#","#"]]
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    setWaiting(true);
    if(grid){
      console.log("entro");
      for(let i = 0; i < rowsClues.length; i++){
        const queryRowClue = `checkRowClues(${i}, ${rowsCluesS}, RowSat, ${squaresS})`;
        pengine.query(queryRowClue, (success, response) => {
          if (success) {
            
            setRowCluesSat((actualValue) => {
              let auxRowCluesSat = [...actualValue];
              auxRowCluesSat[i] = response['RowSat'];
              return auxRowCluesSat;
            });
          }
        });
      }

      for(let j = 0; j < colsClues.length; j++){
        const queryColClue = `checkColClues(${j}, ${colsCluesS}, ColSat, ${squaresS})`;
        pengine.query(queryColClue, (success, response) => {
          if (success) {
            
            setColCluesSat((actualValue) => {
             let auxColCluesSat = [...actualValue];
              auxColCluesSat[j] = response['ColSat'];
            
              return auxColCluesSat;});
          }
        });
      }
    }
    setWaiting(false);
  }

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting || win) {
      return;
    }
    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",,,,],["X",,"X",,],["X",,,,],["#","#","#",,],[,_,"#","#","#"]]
    const content = toggled ? "#" : "X"; // Content to put in the clicked square.
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    const queryS = `put("${content}", [${i},${j}], ${rowsCluesS}, ${colsCluesS}, ${squaresS}, ResGrid, RowSat, ColSat)`; // queryS = put("#",[0,1],[], [],[["X",,,,],["X",,"X",,],["X",,,,],["#","#","#",,],[,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        console.log("---------------------------------------------------------------------");
        setGrid(response['ResGrid']);
        let auxRowCluesSat = [...rowCluesSat];
        auxRowCluesSat[i] = response['RowSat'];
        let auxColCluesSat = [...colCluesSat];
        auxColCluesSat[j] = response['ColSat'];
        setRowCluesSat(auxRowCluesSat);
        setColCluesSat(auxColCluesSat);


      
      }
      setWaiting(false);
    });
  }
  
useEffect(() => {
    gameEnd();
},[colCluesSat, rowCluesSat]);

  function gameEnd(){
    const allRowCluesSatTrue = rowCluesSat.every(value => value === true);
    const allColCluesSatTrue = colCluesSat.every(value => value === true);
    setWin(allRowCluesSatTrue && allColCluesSatTrue);
  }

  if (!grid) {
    return null;
  }

const statusText = win ? 'You win!' : 'Keep playing!';
return (
  <div className="game">
    <div>
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
        rowCluesSat={rowCluesSat}
        colCluesSat={colCluesSat}/>
      <Toggle toggled = {toggled} onClick={handleToggle}/> 
      <br/>
      <br/>
      <div className="game-info">
        {statusText}
      </div>
    </div>
  </div>
);
}

export default Game;