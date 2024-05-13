int a[10];

int main()
{   
    //copying global to local array 
    int i;
    int b[10];
    int c;

    i=0;
    while(i<10)
    {
        a[i]=i+1;
        i=i+1;
    }

    i=0;
    while(i<10)
    {
        b[i]=a[i];
        i=i+1;
    }

    i=0;
    while(i<10)
    {
        c=b[i];
        i=i+1;
        println(c);
    }

}