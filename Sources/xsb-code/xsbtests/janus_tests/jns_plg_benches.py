
def incr(X):
    return X + 1

def kw_incr(X,**kwargs):
    return X + 1

def makelist_noret(N):
    list = []
    for i in range(1,N):
        list.append(i)

def makelist_ret(N):
    list = []
    for i in range(1,N):
        list.append(i)
    return list

def dummy(Dummy):
    return True

class BenchClass:
        
    def __init__(self):
        pass

    def incr(self,N):
        return(N+1)

    def incr_kw(self,N,**kwargs):
        return(N+1)

