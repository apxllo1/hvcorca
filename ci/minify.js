const luamin = require("luamin");
const fs = require("fs");
const path = require("path");

const FILE = path.join(__dirname, "bundle.tmp");

function stripLuaComments(src) {
    let out = "", i = 0, len = src.length;
    while (i < len) {
        if (src[i] === "-" && src[i+1] === "-") {
            let j = i + 2;
            if (src[j] === "[" && src[j+1] === "[") {
                j += 2; const tight=src.indexOf("]]",j),spaced=src.indexOf("]]",j);
                let end,skip; if(tight===-1&&spaced===-1)break;
                if(tight===-1){end=spaced;skip=3}else if(spaced===-1){end=tight;skip=2}
                else{end=spaced<tight?spaced:tight;skip=spaced<tight?3:2} i=end+skip;out+=" ";continue;
            }
            while(i<len&&src[i]!=="\n")i++;continue;
        }
        if(src[i]==='"'||src[i]==="'"){const q=src[i];out+=q;i++;while(i<len&&src[i]!==q){if(src[i]==="\\")out+=src[i++];out+=src[i++]}if(i<len)out+=q,i++;continue;}
        if(src[i]==="["&&src[i+1]==="["){const end=src.indexOf("]]",i+2);if(end===-1){out+=src.slice(i);break}out+=src.slice(i,end+2);i=end+2;continue;}
        out+=src[i++]; } return out;
}

function fixLuau(src){return src.replace(/([a-zA-Z0-9_.]+)\s*\+=/g,"$1=$1+").replace(/([a-zA-Z0-9_.]+)\s*-=/g,"$1=$1-").replace(/([a-zA-Z0-9_.]+)\s*\*=/g,"$1=$1*").replace(/([a-zA-Z0-9_.]+)\s*\/=/g,"$1=$1/").replace(/([a-zA-Z0-9_.]+)\s*\.\.=/g,"$1=$1..").replace(/\bcontinue\b/g,"do break end");}

try{
    let src=fs.readFileSync(FILE,"utf8");console.log(`[Hvcorca v2.0] ${src.length}→? bytes`);
    src=stripLuaComments(src);src=fixLuau(src);
    const min=luamin.minify(src);fs.writeFileSync(FILE,min);
    console.log(`[Hvcorca v2.0] ${min.length} bytes (${Math.round((1-src.length/min.length)*100)}% smaller)`);
}catch(e){console.error("[Hvcorca v2.0] FAILED:",e.message);process.exit(1);}
