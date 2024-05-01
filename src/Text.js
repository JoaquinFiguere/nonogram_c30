import React from 'react';

function Text({ win , text}) {
    return (
        <div className= {"game-info" + (win ? " game-info-win" : "")}>
            {win}
        </div>
    );
}
export default Text;