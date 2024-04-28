import React from 'react';

function Clue({ clue, sat }) {
    console.log(sat);
    return (
        <div className={"clue" + (sat ? " clueSat" : "")} >
            {clue.map((num, i) =>
                <div key={i}>
                    {num}
                </div>
            )}
        </div>
    );
}



export default Clue;