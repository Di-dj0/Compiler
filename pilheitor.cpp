#include <iostream>
#include <vector>
#include <fstream>
#include <stack>
#include <stdio.h>

using namespace std;

struct operacao {
    string rot, instr, arg;
};

vector<operacao> programa;

bool temarg(string &op) {
    return (op=="PUSH" or op=="ATR" or op=="GOTO" or op=="GTRUE" or op=="GFALSE");
}

int rotulo(string &r) {
    for (int i=0;i<(int)programa.size();i++)
        if (programa[i].rot == r)
            return i;
    return 0;
}

int main(int argc, char *argv[]) {

    if (argc != 2) {
        printf("Uso: %s [arquivo.pil]\n", argv[0]);
        return 1;
    }

    // le
    ifstream f(argv[1], ifstream::in);

    string instr;
    do {
        f >> instr;
        operacao o;
        if (instr[0]=='R') {
            o.rot = instr.substr(0, instr.size()-1);
            f >> o.instr;
            if (temarg(o.instr)) f >> o.arg;
        } else {
            o.instr = instr;
            if (temarg(o.instr)) f >> o.arg;
        }
        programa.push_back(o);
    } while (programa[(int)programa.size()-1].instr != "SAIR");
    f.close();

    // roda
    int pc = 0;
    int regs[1024];
    stack<int> S;
    while (programa[pc].instr != "SAIR") {
        instr = programa[pc].instr;
        int val, a, b;
        if (instr == "PUSH") {
            if (programa[pc].arg[0]=='%') {
                sscanf(programa[pc].arg.c_str(), "%%%d", &val);
                val = regs[val];
            } else
                sscanf(programa[pc].arg.c_str(), "%d", &val);
            S.push(val);
            pc++;
        } else if (instr == "ATR") {
            sscanf(programa[pc].arg.c_str(), "%%%d", &val);
            regs[val] = S.top();
            S.pop();
            pc++;
        } else if (instr == "LEIA") {
            cin >> val;
            S.push(val);
            pc++;
        } else if (instr == "IMPR") {
            cout << S.top() << endl;
            S.pop();
            pc++;
        } else if (instr == "SOMA") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( a+b );
            pc++;
        } else if (instr == "SUB") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( b-a );
            pc++;
        } else if (instr == "MULT") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( a*b );
            pc++;
        } else if (instr == "DIV") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( b/a );
            pc++;
        } else if (instr == "MOD") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( b%a );
            pc++;
        } else if (instr == "NADA") {
            pc++;
        } else if (instr == "MAIOR") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( b>a ? 1 : 0 );
            pc++;
        } else if (instr == "MENOR") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( b<a ? 1 : 0 );
            pc++;
        } else if (instr == "MAIOREQ") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( b>=a ? 1 : 0 );
            pc++;
        } else if (instr == "MENOREQ") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( b<=a ? 1 : 0 );
            pc++;
        } else if (instr == "IGUAL") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( a==b ? 1 : 0 );
            pc++;
        } else if (instr == "DIFER") {
            a = S.top(); S.pop();
            b = S.top(); S.pop();
            S.push( a!=b ? 1 : 0 );
            pc++;
        } else if (instr == "GFALSE") {
            val = S.top(); S.pop();
            if (val==0) pc = rotulo(programa[pc].arg);
            else pc++;
        } else if (instr == "GTRUE") {
            val = S.top(); S.pop();
            if (val!=0) pc = rotulo(programa[pc].arg);
            else pc++;
        } else if (instr == "GOTO") {
            pc = rotulo(programa[pc].arg);
        }
    }

    return 0;
}
