#!/usr/bin/python
import os
import sys
import string

def main():
    fo=open(sys.argv[2],'w')
    fi=open(sys.argv[1],'r')
    a=fi.readlines()
    del_a = []
    for x in  range(len(a)):
        if a[x].split()[0] == '#':
            del_a.append(x)
    print del_a
    for x in range(len(del_a)):
        del a[0]
    print a
    mux_o=list(a[3].split()[1])
    for ele in mux_o:
        if ele in string.punctuation:
            mux_o.remove(ele)
    mux_o=''.join(mux_o)
    mux_in1=list(a[3].split()[2])
    for ele in mux_in1:
        if ele in string.punctuation:
            mux_in1.remove(ele)
    mux_in1=''.join(mux_in1)
    mux_in2=list(a[3].split()[3])
    for ele in mux_in2:
        if ele in string.punctuation:
            mux_in2.remove(ele)
    mux_in2=''.join(mux_in2)
    mux_s=list(a[3].split()[4])
    for ele in mux_s:
        if ele in string.punctuation:
            mux_s.remove(ele)
    mux_s=''.join(mux_s)
    bf_o=list(a[5].split()[1])
    for ele in bf_o:
        if ele in string.punctuation:
            bf_o.remove(ele)
    bf_o=''.join(bf_o)
    bf_i=list(a[5].split()[2])
    for ele in bf_i:
        if ele in string.punctuation:
            bf_i.remove(ele)
    bf_i=''.join(bf_i)

    ln=int(a[1].split()[0])
#    print ln
    if ln!=1:
        fo.write('module pdelayline (in, out, s);\n  input [%d:0] s;\n  input in;\n  output out;\n'%(ln-1))
    else:
        fo.write('module pdelayline (in, out, s);\n  input s;\n  input in;\n  output out;\n' )
    layer=[]
    for n in range(ln):
        layer.append(int(a[1].split()[n+1]))
#        print layer[n]
        if n==0:
            if layer[n]!=1:
                fo.write('  wire [%d:0] w%d;\n'%(layer[n]-1,n))
            else:
                fo.write('  wire w%d;\n'%(n))
        else:
            fo.write('  wire [%d:0] w%d;\n'%(layer[n],n))

    if ln==1:
        if layer[0]==1:
            fo.write('\n  %s MUX0 (.%s(out),.%s(in),.%s(w0),.%s(s));' % (a[3].split()[0],mux_o,mux_in1,mux_in2,mux_s))
            fo.write('\n  %s BUF0 (.%s(w0),.%s(in));'%(a[5].split()[0],bf_o,bf_i))
        else:
            fo.write('\n  %s MUX0 (.%s(out),.%s(in),.%s(w0[%d]),.%s(s));' % (a[3].split()[0], mux_o,mux_in1,mux_in2,layer[0]-1,mux_s))
            for m in range(layer[0]):
                if m==0:
                    fo.write('\n  %s BUF0_0 (.%s(w0[0]),.%s(in));' % (a[5].split()[0], bf_o, bf_i))
                else:
                    fo.write('\n  %s BUF0_%d (.%s(w0[%d]),.%s(w0[%d]));' % (a[5].split()[0], m, bf_o, m, bf_i, m - 1))


    else:
        for n in range(ln):
            if n!=ln-1 and n!=0:
                fo.write('\n  %s MUX%d (.%s(w%d[0]),.%s(w%d[0]),.%s(w%d[%d]),.%s(s[%d]));'%(a[3].split()[0],n,mux_o,n+1,mux_in1,n,mux_in2,n,layer[n],mux_s,n))
            elif n==0:
                if layer[0] != 1:
                    fo.write('\n  %s MUX0 (.%s(w1[0]),.%s(in),.%s(w0[%d]),.%s(s[0]));' % (a[3].split()[0],mux_o,mux_in1,mux_in2,layer[n]-1,mux_o))
                else:
                    fo.write('\n  %s MUX0 (.%s(w1[0]),.%s(in),.%s(w0),.%s(s[0]));' % (a[3].split()[0],mux_o,mux_in1,mux_in2,mux_s))
            elif n==ln-1:
                fo.write('\n  %s MUX%d (.%s(out),.%s(w%d[0]),.%s(w%d[%d]),.%s(s[%d]));' % (a[3].split()[0], n,mux_o, mux_in1, n,mux_in2, n, layer[n], mux_s, n))

            if n!=0:
                for m in range(layer[n]):
                    fo.write('\n  %s BUF%d_%d (.%s(w%d[%d]),.%s(w%d[%d]));' % (a[5].split()[0],n,m,bf_o, n,m+1,bf_i,n,m))
            else:
                for m in range(layer[0]):
                    if layer[0] != 1:
                        if m!=0:
                            fo.write('\n  %s BUF0_%d (.%s(w0[%d]),.%s(w0[%d]));' % (a[5].split()[0], m,bf_o, m, bf_i, m-1))
                        else:
                            fo.write('\n  %s BUF0_0 (.%s(w0[0]),.%s(in));' % (a[5].split()[0],bf_o,bf_i))
                    else:
                        fo.write('\n  %s BUF0_0 (.%s(w0),.%s(in));' % (a[5].split()[0],bf_o,bf_i))

    fo.write('\nendmodule')
    fo.close()
    fi.close
    print 'Programmable delay line generated'


if __name__ == "__main__": main()